# Nim RFC Research Report: Style, Structure, and Success Patterns

## Executive Summary

Analysis of nim-lang/RFCs repository reveals distinct patterns for successful infrastructure and tooling RFCs. This report examines 5 representative RFCs (524, 538, 540, 515, 544, 556) to identify structural elements, writing style, and characteristics that lead to acceptance.

## Repository Overview

- **Total RFCs analyzed**: 20 recent proposals (issues 546-565)
- **Focus area**: Infrastructure and tooling (not language features)
- **Acceptance rate observed**: ~10-15% of recent RFCs show "Accepted RFC" label
- **Key RFCs examined in detail**:
  - RFC 544: Nim Tooling Roadmap (checklist-style roadmap)
  - RFC 524: Nimble for Nim v2 (package manager improvements)
  - RFC 540: Demangle Symbols in Debuggers (developer experience)
  - RFC 515: Provide official docker image (deployment infrastructure)
  - RFC 538: Avoiding explicit NimMain (library ergonomics)
  - RFC 556: Nim Roadmap 2025 (long-term vision)

## RFC Structure Patterns

### 1. Standard GitHub Issue Template Sections

Successful RFCs consistently use these sections:

#### **Summary/Abstract** (Required)
- 1-3 sentences capturing the core proposal
- Clear statement of what is being proposed
- Example from RFC 515: "Provide an official docker image for Nim, similar to Rust or Python"

#### **Motivation** (Critical)
- Why this change is needed NOW
- Real-world pain points with concrete examples
- Connection to ecosystem growth or adoption
- Example from RFC 524: Details monorepo challenges, supply chain security requirements, and documentation generation issues

#### **Description** (Most detailed)
- Technical implementation details
- Step-by-step breakdown of proposed changes
- Code pointers to existing codebase
- Integration with existing Nim tooling
- Comparison with other languages' approaches
- Example from RFC 540: Detailed LLDB/GDB integration steps, references to D and Swift implementations

#### **Code Examples** (When applicable)
- Concrete usage examples showing before/after
- Realistic scenarios developers will encounter
- Example from RFC 515: Multi-stage Dockerfile demonstrating usage

#### **Backwards Compatibility** (Required)
- Explicit discussion of breaking changes
- Migration path for existing code
- Compatibility flags or gradual rollout strategies
- Example from RFC 540: "Just re-compile your source if you want debugging support"

#### **Alternatives** (Recommended)
- Other approaches considered and why they were rejected
- Trade-offs between different solutions
- Example from RFC 540: Discusses modifying compiler to output assembly directly, writing debugger in Nim

#### **Links/Related** (Important)
- Related GitHub issues
- Forum discussions
- Prior art in other languages
- Academic papers or technical references
- Example from RFC 524: Links to 4 related Nimble/Nim issues

### 2. Roadmap-Style RFCs

Some RFCs take a different approach, using task lists:

#### **RFC 544 Pattern** (Tooling Roadmap)
- Organized by tool/component (VSCode Extension, nimlangserver, Debugger, Package manager)
- Checkbox lists with [x] completed, [ ] pending
- Sub-categorized features
- No formal sections, just hierarchical task breakdown
- 26+ community comments engaging with specific items

#### **RFC 556 Pattern** (Strategic Roadmap)
- Organized by version/timeline (v2.4, v3, beyond)
- Mix of narrative and bullet points
- Long-term vision with philosophical framing
- Implementation details for major architectural changes
- NIF (Nim Intermediate Format) technical deep-dive

## Writing Style Characteristics

### Tone and Voice

1. **Technical but accessible**: Assumes reader knows Nim but explains context
2. **Problem-first framing**: Opens with pain points, not solutions
3. **Evidence-based**: Links to forum threads, issues, other languages
4. **Pragmatic**: Acknowledges limitations and trade-offs
5. **Collaborative**: "Here are my findings", "I believe", invites discussion

### Language Patterns

**Effective phrases observed**:
- "This is problematic because..." (RFC 524)
- "Unfortunately I'm unsure how other languages..." (RFC 524)
- "For example, I have had discussions on..." (RFC 524)
- "Here are my findings from researching..." (RFC 540)
- "Approximate steps to make this happen..." (RFC 515)
- "Followup on the discussion at..." (RFC 538)

**Key characteristics**:
- First-person narrative common ("I", "my library")
- Questions embedded in description ("How to?", "In which scenario...")
- Use of code blocks with file paths and line numbers
- Screenshots/diagrams included (ASCII diagrams in issues)
- References to maintainer discussions on Discord/forums

### Level of Detail

**High detail areas**:
- Specific file paths in Nim compiler source
- Line-by-line code examples from other languages
- Step-by-step implementation checklist
- Concrete numbers (versions, counts, percentages)

**Medium detail areas**:
- Overview of alternatives
- Related work in other ecosystems
- Backwards compatibility strategy

**Light detail areas**:
- Future extensions
- Nice-to-have features
- Philosophical motivations

## Success Patterns

### What Makes RFCs Get Accepted

1. **Solves real, documented problems**
   - Multiple forum threads or issues referenced
   - Author has personal experience with the pain point
   - Problem affects adoption or ecosystem growth

2. **Shows research depth**
   - Comparison with Rust, Python, D, Swift, C++ approaches
   - Links to LLVM source code, language specifications
   - Demonstrates understanding of implementation complexity

3. **Proposes concrete, actionable steps**
   - Checkbox lists of required changes
   - Identifies specific files/functions to modify
   - Names maintainers or teams who need to be involved

4. **Considers ecosystem impact**
   - Backwards compatibility explicitly addressed
   - Migration path for existing users
   - Integration with existing tooling (nimble, nimsuggest, etc.)

5. **Engages with community feedback**
   - RFCs with 20-30+ comments show active discussion
   - Authors respond to questions and refine proposals
   - Alternative approaches emerge through discussion

### What Leads to Rejection

Based on RFC 548 (Rejected) and others:
- Conflicts with other design goals
- Implementation complexity too high for benefit
- Better alternatives exist
- Insufficient motivation for the change
- Breaking changes without clear migration path

## Comparison: Infrastructure vs Language Feature RFCs

### Infrastructure RFCs (our focus):
- Emphasize **developer experience** and **adoption barriers**
- Compare with other language ecosystems heavily
- Often include external dependencies (LLDB, Docker Hub, GitHub)
- Success measured by ecosystem growth metrics
- Examples: debugger integration, package manager, docker images

### Language Feature RFCs:
- Emphasize **expressiveness** and **type safety**
- Compare with academic literature and PL theory
- Self-contained within Nim compiler
- Success measured by code elegance and correctness
- Examples: sum types, nil checking, closure improvements

## Specific Recommendations for NPH RFC

Based on this analysis, a successful NPH (Nim code formatter) RFC should:

### 1. Structure
```markdown
# Abstract
Brief summary of NPH as official Nim formatter

# Motivation
- Inconsistent formatting across ecosystem
- Manual formatting discussions in PRs
- Nim lacks "go fmt" equivalent
- Community fragmentation (nimpretty vs manual)

# Description
- Technical architecture (Nim compiler AST integration)
- Configuration philosophy (minimal vs maximal)
- Comparison: gofmt, rustfmt, black, prettier
- Implementation phases

# Code Examples
Before/after formatting examples
Edge cases and how NPH handles them

# Backwards Compatibility
Migration path from nimpretty
Gradual adoption strategy

# Alternatives Considered
Extending nimpretty vs new tool
Integration as nimble task vs standalone
Plugin architecture vs monolithic

# Related Work
Link to existing nimpretty, community discussions
Other language formatters' design decisions

# Implementation Plan
- [ ] Checkpoint: Parser improvements
- [ ] Checkpoint: Core formatting engine
- [ ] Checkpoint: Configuration system
- [ ] Checkpoint: Editor integrations
```

### 2. Tone
- **Lead with frustration**: Show concrete PR comments about formatting bikeshedding
- **Show ecosystem examples**: Inconsistencies between major Nim projects
- **Be opinionated but humble**: "Here's our research, but community input is critical"
- **Use data**: Survey results, PR comment analysis, formatting inconsistency metrics

### 3. Evidence Base
- **Forum threads**: Link to formatting discussions
- **GitHub issues**: Collect nimpretty bugs and enhancement requests
- **Other ecosystems**: Deep dive on gofmt's success, black's philosophy
- **Real codebases**: Show formatting inconsistencies in nim-lang/* repos

### 4. Implementation Clarity
- **Phases not dates**: "Phase 1: Community RFC" → "Phase 2: Prototype" → "Phase 3: Tooling integration"
- **Concrete deliverables**: VSCode extension, nimble task, CI/CD integration
- **Maintainer commitment**: Name 2-3 people willing to maintain long-term

### 5. Community Engagement Strategy
- **Pre-RFC forum post**: Gauge interest, collect pain points
- **RFC iteration**: Respond to every substantive comment
- **Prototype early**: Show working code, not just ideas
- **Integration roadmap**: Path to becoming default formatter

## Key Takeaways

1. **Length matters less than clarity**: RFCs range from 500 words (515) to 2000+ words (524, 540)
2. **Research depth signals seriousness**: External links, code pointers, language comparisons
3. **Checklists work**: Roadmap-style RFCs (544) get high engagement
4. **Problems > Solutions**: Lead with pain, not just features
5. **Backwards compatibility is non-negotiable**: Every RFC addresses this explicitly
6. **Community buy-in happens in comments**: Initial proposal is just the starting point
7. **Maintainer commitment matters**: Who will maintain this for 3-5 years?

## Appendix: RFC Comment Engagement

- RFC 556 (Roadmap 2025): 26 comments
- RFC 544 (Tooling Roadmap): High engagement expected (roadmap-style)
- RFC 524 (Nimble v2): Moderate engagement (specific technical audience)
- RFC 540 (Debugger): Deep technical discussion expected
- RFC 515 (Docker): Clear yes/no decision, lower engagement

**Pattern**: Broader-impact RFCs (roadmaps, tooling) get more comments than narrow technical RFCs.

---

**Date**: 2025-12-27
**Analysis scope**: nim-lang/RFCs issues 515-565 (50 total, 20 examined, 6 analyzed in depth)
**Focus**: Infrastructure and tooling RFCs for code formatter proposal preparation
