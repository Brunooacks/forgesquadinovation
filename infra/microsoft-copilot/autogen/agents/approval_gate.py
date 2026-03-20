"""
ForgeSquad — Human-in-the-Loop Approval Gate for AutoGen

Implements checkpoint management with support for:
1. Console mode — interactive approval via terminal
2. Teams mode — sends notification via webhook, polls for response
3. Auto-approve mode — for testing and CI pipelines
"""

import hashlib
import logging
import os
from dataclasses import dataclass, field
from datetime import datetime, timezone

import httpx

logger = logging.getLogger(__name__)


@dataclass
class ApprovalRequest:
    """Request for human approval at a pipeline checkpoint."""
    run_id: str
    checkpoint_number: int
    phase_name: str
    artifact_summary: str
    artifact_hash: str
    approvers: list[str] = field(default_factory=lambda: ["admin@company.com"])
    timeout_minutes: int = 1440  # 24 hours


@dataclass
class ApprovalResult:
    """Result of an approval decision."""
    decision: str  # "approved", "rejected", "modified"
    decided_by: str
    comments: str
    decided_at: str
    artifact_hash: str


class ApprovalGate:
    """
    Manages human-in-the-loop approval gates for ForgeSquad pipeline checkpoints.

    Supports three modes:
    - console: Interactive terminal input (development)
    - teams: Microsoft Teams webhook notifications (production)
    - auto_approve: Automatic approval (testing/CI)
    """

    def __init__(
        self,
        mode: str | None = None,
        auto_approve: bool = False,
        teams_webhook_url: str | None = None,
        approval_api_url: str | None = None,
    ):
        if auto_approve:
            self.mode = "auto_approve"
        else:
            self.mode = mode or os.getenv("APPROVAL_MODE", "console")

        self.teams_webhook_url = (
            teams_webhook_url or os.getenv("TEAMS_WEBHOOK_URL", "")
        )
        self.approval_api_url = (
            approval_api_url or os.getenv("APPROVAL_API_URL", "")
        )

    async def request_approval(self, request: ApprovalRequest) -> ApprovalResult:
        """
        Requests human approval for a checkpoint.

        First validates artifact integrity via SHA-256 hash,
        then delegates to the appropriate approval method.
        """
        # Validate artifact integrity
        computed_hash = hashlib.sha256(
            request.artifact_summary.encode()
        ).hexdigest()

        if computed_hash != request.artifact_hash:
            logger.error(
                "Artifact hash mismatch at checkpoint %d! "
                "Expected: %s, Got: %s",
                request.checkpoint_number,
                request.artifact_hash,
                computed_hash,
            )
            return ApprovalResult(
                decision="rejected",
                decided_by="System (Integrity Check)",
                comments="SECURITY: Artifact hash mismatch. Possible tampering detected.",
                decided_at=datetime.now(timezone.utc).isoformat(),
                artifact_hash=computed_hash,
            )

        if self.mode == "auto_approve":
            return self._auto_approve(request)
        elif self.mode == "teams":
            return await self._teams_approval(request)
        else:
            return await self._console_approval(request)

    def _auto_approve(self, request: ApprovalRequest) -> ApprovalResult:
        """Automatically approves (for testing/CI)."""
        logger.info(
            "Auto-approving checkpoint %d (%s)",
            request.checkpoint_number,
            request.phase_name,
        )
        return ApprovalResult(
            decision="approved",
            decided_by="AutoApprove (Test Mode)",
            comments="Automatically approved in test mode",
            decided_at=datetime.now(timezone.utc).isoformat(),
            artifact_hash=request.artifact_hash,
        )

    async def _console_approval(self, request: ApprovalRequest) -> ApprovalResult:
        """Interactive console approval for development."""

        separator = "=" * 60
        print()
        print(separator)
        print(f"  CHECKPOINT {request.checkpoint_number}: {request.phase_name}")
        print(separator)
        print()
        print("Artifact Summary (first 1000 chars):")
        print("-" * 40)
        print(request.artifact_summary[:1000])
        print("-" * 40)
        print()
        print(f"Artifact Hash (SHA-256): {request.artifact_hash[:16]}...")
        print(f"Run ID: {request.run_id}")
        print()
        print("Decision:")
        print("  [A] Approve — continue to next phase")
        print("  [R] Reject  — stop pipeline for review")
        print("  [M] Modify  — request changes and re-run phase")
        print()

        while True:
            choice = input("> ").strip().upper()
            if choice in ("A", "APPROVE"):
                decision = "approved"
                break
            elif choice in ("R", "REJECT"):
                decision = "rejected"
                break
            elif choice in ("M", "MODIFY"):
                decision = "modified"
                break
            else:
                print("Invalid choice. Enter A, R, or M.")

        comments = input("Comments (optional, press Enter to skip): ").strip()

        print()
        logger.info(
            "Checkpoint %d: %s (by Console User)",
            request.checkpoint_number,
            decision,
        )

        return ApprovalResult(
            decision=decision,
            decided_by="Console User",
            comments=comments,
            decided_at=datetime.now(timezone.utc).isoformat(),
            artifact_hash=request.artifact_hash,
        )

    async def _teams_approval(self, request: ApprovalRequest) -> ApprovalResult:
        """
        Sends approval request to Microsoft Teams via webhook
        and polls for a response.
        """
        if not self.teams_webhook_url:
            logger.warning("Teams webhook URL not configured. Falling back to console.")
            return await self._console_approval(request)

        # Build Adaptive Card payload
        card_payload = {
            "type": "message",
            "attachments": [
                {
                    "contentType": "application/vnd.microsoft.card.adaptive",
                    "content": {
                        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                        "type": "AdaptiveCard",
                        "version": "1.5",
                        "body": [
                            {
                                "type": "TextBlock",
                                "text": f"ForgeSquad Checkpoint {request.checkpoint_number}",
                                "weight": "Bolder",
                                "size": "Large",
                            },
                            {
                                "type": "TextBlock",
                                "text": f"Phase: {request.phase_name}",
                                "weight": "Bolder",
                            },
                            {
                                "type": "TextBlock",
                                "text": f"Run ID: {request.run_id}",
                                "isSubtle": True,
                            },
                            {
                                "type": "TextBlock",
                                "text": "Artifact Summary:",
                                "weight": "Bolder",
                                "separator": True,
                            },
                            {
                                "type": "TextBlock",
                                "text": request.artifact_summary[:500],
                                "wrap": True,
                            },
                            {
                                "type": "FactSet",
                                "facts": [
                                    {
                                        "title": "Hash",
                                        "value": request.artifact_hash[:16] + "...",
                                    },
                                    {
                                        "title": "Timeout",
                                        "value": f"{request.timeout_minutes} min",
                                    },
                                ],
                            },
                        ],
                        "actions": [
                            {
                                "type": "Action.Submit",
                                "title": "Approve",
                                "style": "positive",
                                "data": {
                                    "decision": "approved",
                                    "checkpoint": request.checkpoint_number,
                                    "run_id": request.run_id,
                                },
                            },
                            {
                                "type": "Action.Submit",
                                "title": "Reject",
                                "style": "destructive",
                                "data": {
                                    "decision": "rejected",
                                    "checkpoint": request.checkpoint_number,
                                    "run_id": request.run_id,
                                },
                            },
                        ],
                    },
                }
            ],
        }

        # Send to Teams
        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(
                    self.teams_webhook_url,
                    json=card_payload,
                    timeout=30.0,
                )
                response.raise_for_status()
                logger.info(
                    "Teams notification sent for checkpoint %d",
                    request.checkpoint_number,
                )
            except httpx.HTTPError as e:
                logger.error("Failed to send Teams notification: %s", e)
                logger.info("Falling back to console approval")
                return await self._console_approval(request)

        # Poll for response via approval API
        if not self.approval_api_url:
            logger.warning(
                "Approval API URL not configured. "
                "Falling back to console for response."
            )
            return await self._console_approval(request)

        import asyncio

        poll_interval = 30  # seconds
        max_polls = (request.timeout_minutes * 60) // poll_interval

        async with httpx.AsyncClient() as client:
            for _ in range(max_polls):
                try:
                    resp = await client.get(
                        f"{self.approval_api_url}/approvals/{request.run_id}/{request.checkpoint_number}",
                        timeout=10.0,
                    )
                    if resp.status_code == 200:
                        data = resp.json()
                        if data.get("is_completed"):
                            return ApprovalResult(
                                decision=data.get("decision", "rejected"),
                                decided_by=data.get("decided_by", "Teams User"),
                                comments=data.get("comments", ""),
                                decided_at=datetime.now(timezone.utc).isoformat(),
                                artifact_hash=request.artifact_hash,
                            )
                except httpx.HTTPError:
                    pass  # Continue polling

                await asyncio.sleep(poll_interval)

        # Timeout
        logger.warning(
            "Checkpoint %d timed out after %d minutes",
            request.checkpoint_number,
            request.timeout_minutes,
        )
        return ApprovalResult(
            decision="rejected",
            decided_by="System (Timeout)",
            comments=f"Approval timed out after {request.timeout_minutes} minutes",
            decided_at=datetime.now(timezone.utc).isoformat(),
            artifact_hash=request.artifact_hash,
        )


def verify_audit_trail(audit_trail: list[dict]) -> dict:
    """
    Verifies the integrity of an audit trail by checking the hash chain.

    Args:
        audit_trail: List of audit events in chronological order.

    Returns:
        Verification result with valid flag and any issues found.
    """
    if not audit_trail:
        return {"valid": False, "message": "Empty audit trail"}

    issues: list[str] = []
    expected_prev = "genesis"

    for i, event in enumerate(audit_trail):
        # Check previous hash chain
        if event.get("previous_hash") != expected_prev:
            issues.append(
                f"Event {i}: previous hash mismatch "
                f"(expected {expected_prev[:8]}..., got {event.get('previous_hash', 'N/A')[:8]}...)"
            )

        # Recompute event hash
        content = (
            f"{event['run_id']}|{event['event_type']}|{event['phase']}|"
            f"{event['agent']}|{event['message']}|{event.get('previous_hash', 'genesis')}"
        )
        computed = hashlib.sha256(content.encode()).hexdigest()

        if event.get("event_hash") != computed:
            issues.append(
                f"Event {i}: hash mismatch "
                f"(stored {event.get('event_hash', 'N/A')[:8]}..., "
                f"computed {computed[:8]}...)"
            )

        expected_prev = event.get("event_hash", "")

    return {
        "valid": len(issues) == 0,
        "total_events": len(audit_trail),
        "issues": issues,
        "message": (
            "Audit trail integrity verified"
            if not issues
            else f"INTEGRITY VIOLATION: {len(issues)} issues found"
        ),
    }
