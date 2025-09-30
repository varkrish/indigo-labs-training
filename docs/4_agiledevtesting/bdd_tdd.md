## BDD and TDD (Brief Introduction)

## What is TDD?

Test-Driven Development (TDD) is a practice where you write a failing test first, implement the minimum code to make it pass, and then refactor. The rhythm is Red → Green → Refactor. TDD improves design, keeps code testable, and gives fast feedback.

## What is BDD?

Behavior-Driven Development (BDD) builds on TDD by describing system behavior in business-friendly language. It aligns stakeholders and developers around shared, executable examples of how the system should behave.

## What is Gherkin?

Gherkin is a plain-text syntax used in BDD to express behaviors via Given–When–Then steps. It is readable by non-technical stakeholders and automatable by test frameworks.

### Small Example (Gherkin)

```gherkin
Feature: Shopping cart totals
  As a shopper
  I want my cart total to include tax
  So that I know what I will pay

  Scenario: Calculate total with tax
    Given my cart has an item priced $100
    And the sales tax rate is 10%
    When I view my cart total
    Then the total should be $110
```

## When to Use

- Use TDD to guide low-level design and ensure units are correct.
- Use BDD (with Gherkin) to capture behaviors that matter to users and the business.

## Learn More

- Requirement-centric development and how BDD fits: [Requirement-Centric Development](./requirement_centric_development.md)
- BDD concepts and Gherkin: `https://cucumber.io/docs/bdd/`
- TDD overview: `https://martinfowler.com/bliki/TestDrivenDevelopment.html`

This page is intentionally concise and introductory. Refer to the links above for deeper, hands-on guidance.

## Quick Examples

### React Native (TDD)

```typescript
// sum.test.ts
import { sum } from './sum';

test('sum adds numbers', () => {
  expect(sum(2, 3)).toBe(5);
});
```

```typescript
// sum.ts
export const sum = (a: number, b: number) => a + b;
```

### .NET (TDD)

```csharp
// MathTests.cs
using Xunit;

public class MathTests
{
    [Fact]
    public void Sum_AddsNumbers()
    {
        Assert.Equal(5, MathUtil.Sum(2, 3));
    }
}
```

```csharp
public static class MathUtil
{
    public static int Sum(int a, int b) => a + b;
}
```
