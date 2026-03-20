using System.ComponentModel;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.Agents;
using Microsoft.SemanticKernel.Connectors.AzureOpenAI;

namespace ForgeSquad.Core.Agents;

/// <summary>
/// The Finance Advisor agent specializes in regulatory compliance for
/// financial technology projects. It validates conformity with Bacen,
/// BIAN, Basel III/IV, LGPD, SOX, PCI-DSS, and Open Finance regulations.
/// </summary>
public static class FinanceAdvisorAgent
{
    public const string AgentName = "FinanceAdvisor";
    public const string ModelDeployment = "forgesquad-gpt4o"; // Premium tier for compliance

    private const string SystemPrompt = """
        You are the **Finance Advisor** of ForgeSquad, a specialist in regulatory compliance
        and governance for financial technology projects.

        ## Your Role
        You act as a regulatory consultant, ensuring that all technical and architectural
        decisions comply with applicable regulations. You participate primarily in the
        Architecture, Planning, and Deployment phases, but can be consulted at any time.

        ## Responsibilities
        1. **Regulatory Compliance**: Validate adherence to Bacen, CVM, Susep regulations
        2. **BIAN Framework**: Ensure alignment with Banking Industry Architecture Network
        3. **Basel III/IV**: Validate capital and risk requirements
        4. **LGPD/GDPR**: Ensure personal data protection
        5. **SOX**: Internal controls for listed companies
        6. **PCI-DSS**: Payment card data security
        7. **Open Finance**: Compliance with Banco Central standards

        ## Key Regulations Knowledge

        ### Banco Central do Brasil (Bacen)
        - **Resolution 4.893/2021**: Cybersecurity policy — requires documented cybersecurity
          policy, incident response plan, and periodic risk assessments
        - **Resolution 4.658/2018**: Cloud computing — requires risk assessment, data
          residency in Brazil or approved jurisdictions, contractual clauses
        - **Circular 3.909/2018**: Payment institutions — operational requirements
        - **Resolution BCB 85/2021**: Open Finance — API standards, security, consent
        - **Resolution CMN 4.557/2017**: Risk management — operational, credit, market risk

        ### BIAN (Banking Industry Architecture Network)
        - Map services to BIAN Service Domains
        - Follow standardized Service Operations
        - Align with Business Object Model
        - Use BIAN Service Landscape 12.0

        ### Basel III/IV
        - Minimum capital requirements (CET1, Tier 1, Total Capital)
        - Liquidity Coverage Ratio (LCR) >= 100%
        - Net Stable Funding Ratio (NSFR) >= 100%
        - Operational risk via Standardised Approach

        ### LGPD (Lei Geral de Protecao de Dados)
        - Legal basis for processing (consent, legitimate interest, etc.)
        - Data subject rights (access, correction, deletion, portability)
        - Data Protection Impact Assessment (DPIA) when required
        - Data breach notification within 72 hours
        - DPO (Data Protection Officer) designation

        ## Output Format
        For every compliance validation, produce:

        | Regulation | Requirement | Status | Risk | Remediation |
        |-----------|------------|--------|------|-------------|
        | ... | ... | Compliant/Non-Compliant/Partial/N-A | Critical/High/Medium/Low | ... |

        Final verdict: COMPLIANT / PARTIALLY_COMPLIANT / NON_COMPLIANT

        ## Interaction Protocol
        - With **Architect**: Validate architectural decisions against regulations
        - With **Tech Lead**: Guide on required technical controls
        - With **QA**: Define mandatory compliance tests
        - With **Dev Backend**: Validate implementation of controls
        - Always cite specific regulation articles/sections
        - When in doubt, recommend the more conservative approach
        """;

    /// <summary>
    /// Creates the Finance Advisor ChatCompletionAgent with compliance plugins.
    /// </summary>
    public static ChatCompletionAgent Create(Kernel kernel)
    {
        KernelPlugin compliancePlugins = KernelPluginFactory.CreateFromType<CompliancePlugins>();
        kernel.Plugins.Add(compliancePlugins);

        return new ChatCompletionAgent
        {
            Name = AgentName,
            Instructions = SystemPrompt,
            Kernel = kernel,
            Arguments = new KernelArguments(
                new AzureOpenAIPromptExecutionSettings
                {
                    Temperature = 0.1, // Low temperature for compliance accuracy
                    MaxTokens = 4096,
                    TopP = 0.85,
                    DeploymentName = ModelDeployment
                })
        };
    }
}

/// <summary>
/// Compliance validation plugins for the Finance Advisor agent.
/// </summary>
public sealed class CompliancePlugins
{
    [KernelFunction("validate_bacen_compliance")]
    [Description("Validates an artifact or decision against Banco Central do Brasil regulations (4893, 4658, Open Finance)")]
    public async Task<string> ValidateBacenCompliance(
        [Description("Description of the artifact, architecture, or decision to validate")] string artifactDescription,
        [Description("Specific Bacen resolution to check: 4893, 4658, 3909, bcb85, cmn4557, or all")] string resolution = "all")
    {
        var results = new List<ComplianceResult>();

        if (resolution is "all" or "4893")
        {
            results.AddRange(CheckResolution4893(artifactDescription));
        }
        if (resolution is "all" or "4658")
        {
            results.AddRange(CheckResolution4658(artifactDescription));
        }
        if (resolution is "all" or "bcb85")
        {
            results.AddRange(CheckResolutionBcb85(artifactDescription));
        }

        var report = "## Bacen Compliance Validation Report\n\n";
        report += $"**Date:** {DateTime.UtcNow:yyyy-MM-dd HH:mm}\n";
        report += $"**Resolution(s):** {resolution}\n\n";
        report += "| Requirement | Status | Risk | Detail |\n";
        report += "|------------|--------|------|--------|\n";

        foreach (var result in results)
        {
            report += $"| {result.Requirement} | {result.Status} | {result.RiskLevel} | {result.Detail} |\n";
        }

        var criticalCount = results.Count(r => r.RiskLevel == "Critical" && r.Status != "Compliant");
        report += $"\n**Critical non-compliances:** {criticalCount}\n";
        report += $"**Overall:** {(criticalCount == 0 ? "PASS (review recommended)" : "FAIL (remediation required)")}\n";

        return report;
    }

    [KernelFunction("validate_lgpd_compliance")]
    [Description("Validates data processing activities against LGPD (Lei Geral de Protecao de Dados)")]
    public async Task<string> ValidateLgpdCompliance(
        [Description("Description of data processing activities")] string dataProcessingDescription,
        [Description("Types of personal data involved")] string dataTypes,
        [Description("Purpose of data processing")] string processingPurpose)
    {
        return $"""
            ## LGPD Compliance Assessment

            **Date:** {DateTime.UtcNow:yyyy-MM-dd}
            **Scope:** {processingPurpose}

            ### Data Classification
            | Data Type | Category | Sensitive | Legal Basis Required |
            |----------|----------|-----------|---------------------|
            | {dataTypes} | To be classified | To be assessed | To be determined |

            ### LGPD Requirements Checklist
            | # | Requirement | Article | Status | Action |
            |---|-----------|---------|--------|--------|
            | 1 | Legal basis defined | Art. 7 | Pending | Define legal basis for each processing activity |
            | 2 | Purpose limitation | Art. 6, I | Pending | Document specific purpose for each data use |
            | 3 | Data minimization | Art. 6, III | Pending | Verify only necessary data is collected |
            | 4 | Consent mechanism | Art. 8 | Pending | Implement granular consent if required |
            | 5 | Data subject rights | Art. 18 | Pending | Implement access, correction, deletion, portability |
            | 6 | Data breach notification | Art. 48 | Pending | Implement 72h notification process |
            | 7 | DPIA required | Art. 38 | Pending | Assess if DPIA is needed |
            | 8 | DPO designated | Art. 41 | Pending | Ensure DPO is designated |
            | 9 | International transfer | Art. 33 | Pending | Verify data residency requirements |
            | 10 | Retention policy | Art. 16 | Pending | Define data retention and deletion schedule |

            ### Technical Controls Required
            - **Encryption at rest:** AES-256 for personal data
            - **Encryption in transit:** TLS 1.3
            - **Access control:** RBAC with least privilege
            - **Audit logging:** All access to personal data must be logged
            - **Anonymization:** For analytics and non-essential processing
            - **Data masking:** For non-production environments

            ### DPIA Assessment
            Processing: {dataProcessingDescription}
            Data Types: {dataTypes}
            Purpose: {processingPurpose}

            **DPIA Required:** Likely YES if processing includes:
            - Large-scale processing of sensitive data
            - Systematic monitoring of individuals
            - Automated decision-making with legal effects
            - Innovative use of technology

            *The Finance Advisor agent will provide detailed assessment based on the specific context.*
            """;
    }

    [KernelFunction("check_bian_alignment")]
    [Description("Checks alignment of a service or API with BIAN Service Landscape")]
    public async Task<string> CheckBianAlignment(
        [Description("Description of the service or API")] string serviceDescription,
        [Description("BIAN domain area: sales_and_service, operations, risk_compliance, business_support, reference_data")] string domainArea = "operations")
    {
        var bianDomains = new Dictionary<string, string[]>
        {
            ["sales_and_service"] = [
                "Customer Offer", "Customer Case Management", "Product Directory",
                "Customer Relationship Management", "Sales Product Agreement",
                "Customer Access Entitlement", "Party Authentication"
            ],
            ["operations"] = [
                "Payment Execution", "Payment Order", "Card Transaction Switch",
                "ACH Fulfillment", "Correspondent Bank Operations",
                "Transaction Authorization", "Card Clearing"
            ],
            ["risk_compliance"] = [
                "Regulatory Compliance", "Fraud Detection", "Credit Risk Models",
                "Operational Risk", "Market Risk", "Liquidity Risk",
                "Anti-Money Laundering", "KYC", "Sanctions Screening"
            ],
            ["business_support"] = [
                "Financial Accounting", "General Ledger", "Regulatory Reporting",
                "Business Architecture", "Enterprise Tax Administration"
            ],
            ["reference_data"] = [
                "Product Design", "Customer Profile", "Party Reference Data",
                "Location Data Management", "Currency Exchange"
            ]
        };

        var domains = bianDomains.GetValueOrDefault(domainArea, bianDomains["operations"]);

        var report = $"""
            ## BIAN Alignment Report

            **Service:** {serviceDescription[..Math.Min(200, serviceDescription.Length)]}
            **Domain Area:** {domainArea}
            **BIAN Version:** 12.0

            ### Candidate Service Domains
            | # | Service Domain | Relevance | Notes |
            |---|---------------|-----------|-------|
            """;

        for (int i = 0; i < domains.Length; i++)
        {
            report += $"| {i + 1} | {domains[i]} | To be assessed | Map service operations |\n";
        }

        report += $"""

            ### Alignment Recommendations
            1. Map each API endpoint to a BIAN Service Operation (Initiate, Execute, Request, Retrieve)
            2. Align data models with BIAN Business Object Model
            3. Follow BIAN naming conventions for resources
            4. Document deviations from BIAN standard with justification

            ### Service Operation Mapping Template
            | API Endpoint | HTTP Method | BIAN Operation | Service Domain |
            |-------------|-------------|----------------|----------------|
            | POST /resource | POST | Initiate | {domains[0]} |
            | PUT /resource/id | PUT | Execute | {domains[0]} |
            | GET /resource/id | GET | Retrieve | {domains[0]} |

            *The Finance Advisor will provide detailed mapping based on the actual API specification.*
            """;

        return report;
    }

    [KernelFunction("generate_compliance_report")]
    [Description("Generates a consolidated compliance report for a project phase")]
    public async Task<string> GenerateComplianceReport(
        [Description("Project name")] string projectName,
        [Description("Phase name (e.g., Architecture, Deployment)")] string phaseName,
        [Description("Summary of artifacts and decisions to include")] string summary)
    {
        return $"""
            # Compliance Report — {projectName}

            **Phase:** {phaseName}
            **Date:** {DateTime.UtcNow:yyyy-MM-dd}
            **Generated by:** ForgeSquad Finance Advisor Agent

            ---

            ## Executive Summary
            {summary[..Math.Min(500, summary.Length)]}

            ## Regulatory Coverage Matrix

            | Regulation | Applicable | Validated | Status | Risk |
            |-----------|-----------|-----------|--------|------|
            | Bacen 4893 (Cybersecurity) | TBD | No | Pending | - |
            | Bacen 4658 (Cloud) | TBD | No | Pending | - |
            | LGPD | Yes | No | Pending | - |
            | SOX | TBD | No | Pending | - |
            | PCI-DSS | TBD | No | Pending | - |
            | Basel III/IV | TBD | No | Pending | - |
            | Open Finance (BCB 85) | TBD | No | Pending | - |
            | BIAN | TBD | No | Pending | - |

            ## Open Findings
            *No findings yet — validations pending.*

            ## Recommendations
            1. Complete all applicable regulation validations before next checkpoint
            2. Schedule compliance review session with Compliance team
            3. Document all regulatory decisions in ADRs

            ## Sign-off
            - [ ] Finance Advisor reviewed
            - [ ] Compliance Officer reviewed
            - [ ] Risk Officer reviewed

            ---
            *Report generated by ForgeSquad. Manual review required before sign-off.*
            """;
    }

    [KernelFunction("classify_data")]
    [Description("Classifies data according to sensitivity levels and identifies LGPD requirements")]
    public async Task<string> ClassifyData(
        [Description("Description of the data to classify")] string dataDescription,
        [Description("Context of how the data will be used")] string usageContext)
    {
        return $"""
            ## Data Classification Report

            **Data:** {dataDescription}
            **Usage:** {usageContext}
            **Date:** {DateTime.UtcNow:yyyy-MM-dd}

            ### Classification
            | Attribute | Value |
            |----------|-------|
            | Confidentiality | To be assessed (Public/Internal/Confidential/Restricted) |
            | Contains Personal Data | To be assessed |
            | Contains Sensitive Data | To be assessed |
            | LGPD Category | To be determined |
            | Retention Period | To be defined |

            ### Required Controls by Classification Level

            #### If Restricted
            - Encryption: AES-256 at rest, TLS 1.3 in transit
            - Access: Individual approval, MFA required
            - Logging: Full audit trail, real-time monitoring
            - Storage: Dedicated encrypted storage, Brazil data residency
            - Backup: Encrypted backups, restricted access

            #### If Confidential
            - Encryption: AES-256 at rest, TLS 1.2+ in transit
            - Access: Role-based, need-to-know
            - Logging: Access logging
            - Storage: Standard encrypted storage

            #### If Internal
            - Encryption: TLS in transit
            - Access: Role-based
            - Logging: Standard logging

            *The Finance Advisor will provide the actual classification based on data analysis.*
            """;
    }

    // Helper methods for Bacen compliance checks
    private static List<ComplianceResult> CheckResolution4893(string description)
    {
        return
        [
            new("4893 Art.3 - Cybersecurity Policy", "Pending Review", "High",
                "Documented cybersecurity policy required"),
            new("4893 Art.6 - Incident Response Plan", "Pending Review", "Critical",
                "Incident response plan with defined procedures required"),
            new("4893 Art.8 - Periodic Risk Assessment", "Pending Review", "High",
                "Annual cybersecurity risk assessment required"),
            new("4893 Art.12 - Vulnerability Management", "Pending Review", "High",
                "Continuous vulnerability scanning and remediation required"),
            new("4893 Art.16 - Third Party Risk", "Pending Review", "Medium",
                "Due diligence for cloud and third-party providers required"),
        ];
    }

    private static List<ComplianceResult> CheckResolution4658(string description)
    {
        return
        [
            new("4658 Art.3 - Cloud Risk Assessment", "Pending Review", "Critical",
                "Formal risk assessment before cloud adoption required"),
            new("4658 Art.5 - Data Residency", "Pending Review", "Critical",
                "Data must reside in Brazil or approved jurisdictions"),
            new("4658 Art.11 - Contractual Clauses", "Pending Review", "High",
                "Specific contractual clauses with cloud provider required"),
            new("4658 Art.15 - Bacen Notification", "Pending Review", "High",
                "Banco Central must be notified of cloud services usage"),
            new("4658 Art.16 - Exit Strategy", "Pending Review", "Medium",
                "Documented exit/migration strategy required"),
        ];
    }

    private static List<ComplianceResult> CheckResolutionBcb85(string description)
    {
        return
        [
            new("BCB85 - API Standards", "Pending Review", "High",
                "APIs must follow Open Finance technical specification"),
            new("BCB85 - Consent Management", "Pending Review", "Critical",
                "Granular consent management with revocation required"),
            new("BCB85 - Security Standards", "Pending Review", "Critical",
                "OAuth 2.0 with FAPI profile required"),
            new("BCB85 - Availability SLA", "Pending Review", "High",
                "99.5% availability for shared APIs required"),
        ];
    }

    private record ComplianceResult(string Requirement, string Status, string RiskLevel, string Detail);
}
