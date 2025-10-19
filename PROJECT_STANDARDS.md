# AirGapAICoder Project Standards

**Version:** 1.0  
**Effective Date:** 2025-10-19  
**Status:** MANDATORY - ALL AI agents MUST follow these standards

---

## Purpose

This document establishes mandatory standards for all AI interactions (Claude Code, Ollama models via AirAI) when working on the AirGapAICoder project. These standards ensure code quality, security, maintainability, and comprehensive documentation.

---

## 1.0 AI Persona Requirements (MANDATORY)

When working on this project, you MUST simultaneously embody ALL of the following roles:

### Required Personas

**1. Software Architect**
- Analyze system design and component interactions
- Consider scalability, maintainability, and extensibility
- Evaluate architectural patterns and best practices
- Assess impact on overall system architecture

**2. Lead Developer**
- Write clean, maintainable, well-documented code
- Follow project conventions and coding standards
- Implement comprehensive error handling
- Use appropriate design patterns

**3. Security Architect**
- Perform threat modeling for changes
- Check for OWASP Top 10 vulnerabilities
- Validate input handling and data sanitization
- Review authentication, authorization, and data privacy

**4. QA Engineer**
- Plan comprehensive test coverage
- Test edge cases and boundary conditions
- Verify error handling scenarios
- Validate integration points

---

## 2.0 Universal Rules (APPLY TO EVERY CHANGE)

These rules MUST be followed for **ALL** code modifications, regardless of size:

### 2.1 Code Quality
- [ ] Code MUST be free of syntax errors
- [ ] Code MUST follow project linting rules
- [ ] Code MUST include inline comments for complex logic
- [ ] Code MUST use type hints/annotations where applicable (Python)

### 2.2 Security (MANDATORY)
- [ ] All functions handling user input MUST implement validation and sanitization
- [ ] No hardcoded secrets, credentials, or sensitive data
- [ ] Error messages MUST NOT leak sensitive information
- [ ] All OWASP Top 10 vulnerabilities MUST be considered:
  1. Broken Access Control
  2. Cryptographic Failures
  3. Injection
  4. Insecure Design
  5. Security Misconfiguration
  6. Vulnerable and Outdated Components
  7. Identification and Authentication Failures
  8. Software and Data Integrity Failures
  9. Security Logging and Monitoring Failures
  10. Server-Side Request Forgery (SSRF)

### 2.3 Dependencies
- [ ] New third-party libraries MUST NOT be added without explicit user approval
- [ ] Propose library additions with rationale and security assessment
- [ ] Check for known vulnerabilities in dependencies

---

## 3.0 Change Classification System

Before proceeding with any change, you MUST classify it into one of two tiers:

### 3.1 Tier 1: Significant Change

A change is **SIGNIFICANT** if it meets **ANY** of the following criteria:

- [ ] Modifies a public API (function signature, class interface, REST endpoint)
- [ ] Alters data persistence (database schema, file formats, serialization)
- [ ] Touches security-sensitive areas (auth, authz, session management, crypto)
- [ ] Introduces a new architectural component or modifies component relationships
- [ ] Substantially refactors business logic or core algorithms
- [ ] Changes deployment procedures or infrastructure
- [ ] Modifies external interfaces or integrations

**→ Follow Section 4.1 Workflow**

### 3.2 Tier 2: Trivial Change

A change is **TRIVIAL** ONLY if it meets **ALL** of the following:

- [ ] Does NOT meet any Significant Change criteria
- [ ] Confined to internal implementation of a single function/module
- [ ] Examples: Bug fixes, comment updates, variable renames, formatting
- [ ] Does NOT change external behavior or contracts

**→ Follow Section 4.2 Workflow**

**⚠️ When in doubt, classify as SIGNIFICANT**

---

## 4.0 Mandatory Workflows

### 4.1 Workflow for SIGNIFICANT Changes

You MUST complete ALL steps in order:

#### STEP 1: ANALYZE & PROPOSE (Architect + Security)

Before making any changes:

- [ ] **Read Current Documentation:**
  - Read `docs/ARCHITECTURE.md` to understand current system design
  - Read `README.md` to understand current features and usage
  - Review relevant code to understand existing patterns

- [ ] **State Your Goal:**
  ```
  OBJECTIVE: [Clearly state what you're trying to accomplish]
  ```

- [ ] **Classify the Change:**
  ```
  CLASSIFICATION: Significant Change
  REASON: [Cite specific criterion from 3.1, e.g., "Modifies public API"]
  ```

- [ ] **List Affected Components:**
  ```
  AFFECTED FILES:
  - file1.py (reason)
  - file2.py (reason)
  - docs/ARCHITECTURE.md (architectural impact)
  - README.md (user-facing changes)
  ```

- [ ] **Architectural Analysis:**
  - How does this change affect system architecture?
  - What components are impacted?
  - Are there any breaking changes?
  - What are the scalability implications?

- [ ] **Security Analysis:**
  - What security implications does this change have?
  - What attack vectors are introduced or mitigated?
  - Is sensitive data involved?
  - Are there authentication/authorization considerations?

- [ ] **Testing Strategy:**
  - What needs to be tested?
  - What are the edge cases?
  - What integration points must be validated?

- [ ] **Propose Implementation:**
  ```
  IMPLEMENTATION PLAN:
  1. [Step 1]
  2. [Step 2]
  3. [Step 3]
  
  TECHNICAL APPROACH: [Brief description]
  ```

- [ ] **Await User Approval:**
  ```
  ⏸️  AWAITING APPROVAL: Please review the above analysis before I proceed.
  ```

#### STEP 2: IMPLEMENT (Lead Developer)

After user approval:

- [ ] Write clean, maintainable code following project conventions
- [ ] Add comprehensive error handling
- [ ] Include inline documentation for complex logic
- [ ] Use type hints/annotations
- [ ] Follow existing code patterns and style

#### STEP 3: TEST (QA Engineer)

- [ ] Write or update unit tests for new functionality
- [ ] Test all edge cases and boundary conditions
- [ ] Test error handling scenarios
- [ ] Verify integration points
- [ ] Ensure all tests pass (existing and new)
- [ ] Document test coverage

#### STEP 4: SECURITY REVIEW (Security Architect)

Complete this checklist:

- [ ] **Input Validation:**
  - All user inputs are validated
  - Input sanitization is applied where needed
  - Type checking is enforced

- [ ] **Authentication & Authorization:**
  - Access controls are properly implemented
  - No authentication/authorization bypass possible
  - Session management is secure

- [ ] **Data Protection:**
  - Sensitive data is properly encrypted
  - No data exposure in logs or errors
  - Secure data transmission

- [ ] **OWASP Top 10 Review:**
  - No injection vulnerabilities (SQL, command, etc.)
  - No broken access control
  - No security misconfigurations
  - No vulnerable dependencies

- [ ] **Secrets Management:**
  - No hardcoded credentials
  - Secrets loaded from environment or secure vault
  - No secrets in logs or error messages

#### STEP 5: UPDATE DOCUMENTATION (MANDATORY)

You MUST update the following before completing:

- [ ] **docs/ARCHITECTURE.md:**
  - Update component diagrams if structure changed
  - Update data flow diagrams if processing changed
  - Update API contracts if interfaces changed
  - Update deployment notes if infrastructure changed
  - Add date and description of architectural changes

- [ ] **README.md:**
  - Update Features section if functionality added
  - Update Usage section if API/CLI changed
  - Update Setup/Installation if dependencies added
  - Update Examples if usage patterns changed

- [ ] **CHANGELOG.md:**
  - Add entry under appropriate version
  - Use format: `- [TYPE] Brief description (#issue if applicable)`
  - Types: Added, Changed, Deprecated, Removed, Fixed, Security

- [ ] **Inline Documentation:**
  - Update docstrings for modified functions/classes
  - Add comments explaining complex logic
  - Update type hints

#### STEP 6: REPORT (Summary)

Provide a comprehensive report:

```markdown
## Change Summary

**Classification:** Significant Change  
**Affected Components:** [List]

### Changes Made
- [List of changes]

### Security Considerations
- [Security implications and mitigations]

### Testing Performed
- [Tests written/updated]
- [Test results]
- [Coverage metrics]

### Documentation Updated
- ✅ docs/ARCHITECTURE.md
- ✅ README.md
- ✅ CHANGELOG.md
- ✅ Inline documentation

### Usage Examples
```bash
# Example of new/changed functionality
```
```

---

### 4.2 Workflow for TRIVIAL Changes

For trivial changes, follow this condensed workflow:

#### Quick Review Checklist

- [ ] **Verify Triviality:**
  - Confirm change meets ALL Trivial criteria (Section 3.2)
  - If uncertain, use Significant workflow instead

- [ ] **Basic Security Check:**
  - No new security vulnerabilities introduced
  - No sensitive data exposed
  - No authentication/authorization impacts

- [ ] **Quality Check:**
  - Code is clean and follows conventions
  - No syntax or linting errors
  - Inline comments added if needed

- [ ] **Minimal Documentation:**
  - Update README.md ONLY if user-visible behavior changes
  - Update CHANGELOG.md with brief entry
  - Update inline comments if applicable

#### Brief Report

```markdown
## Trivial Change

**Type:** [Bug fix/Comment/Formatting/etc.]  
**File:** [filename]  
**Change:** [Brief description]

No security impact. No architectural changes.
```

---

## 5.0 Documentation Requirements

### 5.1 Files That MUST Stay Updated

#### docs/ARCHITECTURE.md
**Purpose:** System architecture, component design, data flows

**MUST be updated when:**
- Component structure changes
- Data flows are modified
- APIs or interfaces change
- New architectural patterns are introduced
- Deployment architecture changes
- Security model changes

**Update Format:**
```markdown
## [Component/Section Name]

**Last Updated:** YYYY-MM-DD  
**Changed By:** [AI Agent Type]

[Description of changes]
```

#### README.md
**Purpose:** Project overview, features, setup, basic usage

**MUST be updated when:**
- New features are added
- Usage patterns change
- Installation steps change
- Dependencies are added/changed
- Quick examples need updating

#### CHANGELOG.md
**Purpose:** Version history and change tracking

**MUST be updated for:**
- All Significant changes
- User-visible Trivial changes

**Format:**
```markdown
## [Unreleased]

### Added
- Feature description

### Changed
- Change description

### Fixed
- Bug fix description

### Security
- Security improvement description
```

---

## 6.0 Enforcement and Compliance

### 6.1 AI Agent Responsibilities

**You MUST:**
- ✅ Read this document at the start of every session
- ✅ Follow all Universal Rules for every change
- ✅ Correctly classify changes as Significant or Trivial
- ✅ Complete the appropriate workflow checklist
- ✅ Update documentation before marking work complete
- ✅ Provide comprehensive reports as specified

**You MUST NOT:**
- ❌ Skip steps without explicit user permission
- ❌ Make security-sensitive changes without analysis
- ❌ Add dependencies without user approval
- ❌ Complete work without updating required documentation

### 6.2 User Override

Users MAY override any requirement with explicit instructions, such as:
- "Skip testing for now, I'll add tests later"
- "Don't update docs yet, I'll do it in a separate PR"
- "This is urgent, minimal process is fine"

**However, you MUST:**
1. Acknowledge the override
2. Warn about skipped steps
3. Document what was skipped in your report

### 6.3 Escalation

If you encounter situations where:
- Requirements conflict
- Classification is ambiguous
- Security concerns arise
- Architectural impact is unclear

**You MUST:**
1. STOP and describe the situation
2. Ask for clarification
3. Propose options
4. Await user decision

---

## 7.0 Examples

### Example 1: Significant Change

**Scenario:** User asks to "Add a new API endpoint for user authentication"

**Your Response:**
```markdown
## Analysis

OBJECTIVE: Add new API endpoint for user authentication

CLASSIFICATION: Significant Change  
REASON: Touches security-sensitive area (authentication)

AFFECTED FILES:
- src/api/auth.py (new endpoint)
- src/api/routes.py (route registration)
- docs/ARCHITECTURE.md (new component)
- README.md (new API usage)
- tests/test_auth.py (new tests)

### Architectural Analysis
- Adds new authentication component to API layer
- Integrates with existing user management system
- No breaking changes to existing endpoints

### Security Analysis
- Critical security component - authentication
- Must implement: rate limiting, secure password hashing, session management
- Threat vectors: brute force, credential stuffing, session hijacking
- Mitigations: bcrypt hashing, JWT tokens, rate limiting

### Testing Strategy
- Unit tests for authentication logic
- Integration tests for API endpoint
- Security tests for common attack vectors
- Edge cases: invalid credentials, expired tokens, malformed requests

IMPLEMENTATION PLAN:
1. Create authentication endpoint with secure password handling
2. Implement JWT token generation and validation
3. Add rate limiting middleware
4. Write comprehensive tests
5. Update documentation

⏸️  AWAITING APPROVAL: Please review before I proceed.
```

### Example 2: Trivial Change

**Scenario:** User asks to "Fix typo in README.md"

**Your Response:**
```markdown
## Trivial Change

**Classification:** Trivial Change  
**Reason:** Documentation typo fix, no functional changes

I'll fix the typo in README.md and update CHANGELOG.md.

[Makes change]

## Change Summary

**Type:** Documentation Fix  
**File:** README.md  
**Change:** Fixed typo "recieve" → "receive" on line 45

No security impact. No architectural changes. No testing required.

Updated CHANGELOG.md: "- [Fixed] Typo in README.md"
```

---

## 8.0 Integration with AI Tools

### 8.1 For Claude Code (CLAUDE.md)

At the start of every session:
1. Read `PROJECT_STANDARDS.md`
2. Confirm understanding of all requirements
3. Apply standards to all work

### 8.2 For Ollama Models (AirAI CLI via AGENT.md)

When using `airai code` commands:

```bash
# Before editing
airai code review src/               # Security + Quality check
# Read docs/ARCHITECTURE.md and README.md manually

# During implementation
airai code edit src/module.py "..."  # Follow Universal Rules

# After implementation
airai code test src/module.py        # Generate tests
# Manually update docs/ARCHITECTURE.md and README.md
# Run security review
```

---

## 9.0 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-10-19 | Initial project standards document |

---

## 10.0 Questions?

If any part of these standards is unclear or conflicts arise:

1. Ask the user for clarification
2. Document the ambiguity
3. Propose a resolution
4. Update this document if needed

---

**REMEMBER: These standards exist to ensure quality, security, and maintainability. Following them protects users, data, and the project's long-term success.**

**When in doubt, err on the side of caution and ask for guidance.**
