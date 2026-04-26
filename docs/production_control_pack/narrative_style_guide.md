# Narrative and Event Writing Guide

## Voice

The game's voice is:
- **Strategic and readable** first
- **Historically flavored** second
- **Lightly satirical** third
- **Never cruel or sensational**

Base register: a railway ledger layered over a map. Clear modern readability underneath period flavor.

## Humor Rules

### Acceptable humor
- Corporate rival vanity and incompetence
- Bureaucratic inconvenience
- Tycoon greed and overreach
- Absurd contract demands
- Newspaper headline hyperbole (within reason)

### Forbidden humor
- Mocking victims of famine, war, or exploitation
- Slapstick around human suffering
- Cultural caricatures
- Real-world tragedy as disposable joke

## Writing Principles

### 1. Clarity before flavor
Good:
> "Monsoon warning: river-adjacent tracks face flood damage next month. Upgrade bridges or reserve repair funds."

Bad:
> "The heavens are angry! Chaos everywhere!"

### 2. Active voice
Good:
> "The British East India Rail has built track to Patna."

Bad:
> "It has been observed that track has been constructed by the British entity."

### 3. Specific numbers
Good:
> "Deliver 200 tons of coal to Kolkata by March 1860. Reward: ₹5,000."

Bad:
> "Deliver some coal soon for a good reward."

### 4. Player agency
Good:
> "You may pay ₹10,000 to end the strike, or wait 3–7 days."

Bad:
> "A strike has happened and you are helpless."

## Format Templates

### Event Card

```
HEADLINE: 6–10 words, period newspaper style
BODY: 2 short paragraphs max
EFFECT:
  • Clear mechanical bullet 1
  • Clear mechanical bullet 2
CHOICES:
  [Option 1] — cost and effect
  [Option 2] — cost and effect
  [Dismiss] — accept default effect
```

Example:
```
HEADLINE: Monsoon Season Approaches
BODY: Meteorological reports indicate heavy rainfall
expected along the Ganges basin. Engineers warn
that river crossings are vulnerable.
EFFECT:
  • River-adjacent tracks: 30% damage risk
  • Grain demand rises for famine relief
CHOICES:
  [Upgrade Bridges] — ₹8,000, eliminates damage risk
  [Reserve Funds] — No cost, pay repairs if damage occurs
```

### Newspaper Headline (Campaign Briefing)

```
THE BENGAL RAILWAY GAZETTE
Vol. XII, No. 4 — March 1858

[Headline: 4–8 words]
[Subhead: one sentence summary]
[Body: 2–3 sentences of flavor]
[Objective: clear player goal]
```

Example:
```
THE BENGAL RAILWAY GAZETTE
Vol. XII, No. 4 — March 1858

FIRST CHARTER SECURED
Her Majesty's government approves initial
railway construction between Calcutta and inland
stations. Coal and textile trade expected to boom.

Objective: Connect Kolkata to Patna and earn
₹200,000 in net worth.
```

### Contract Text

```
CONTRACT: [Name]
ISSUED BY: [Faction or Government]
TERMS: Deliver [quantity] [cargo] to [city] by [date].
REWARD: ₹[amount] + [reputation bonus]
PENALTY: ₹[amount] + reputation loss for failure
NOTES: [Optional flavor, 1 sentence]
```

Example:
```
CONTRACT: Famine Relief — Dacca
ISSUED BY: Bengal Administration
TERMS: Deliver 300 tons of Grain to Dacca
by June 1858.
REWARD: ₹6,000 + 15 Reputation
PENALTY: ₹2,000 + 10 Reputation loss
NOTES: Urgent relief following poor harvest.
```

### Faction Description

```
[Name]
[One-sentence identity]

Starting Bonus: [Specific mechanical bonus]
AI Behavior: [One-sentence personality]
Historical Note: [Optional, 1 sentence, neutral tone]
```

Example:
```
British East India Rail
The established colonial power with deep
pockets and aggressive expansion goals.

Starting Bonus: +20% starting capital
AI Behavior: Builds trunk routes first,
accepts high risk for market control.
```

### Warning Notification

```
[Icon] [Title]
[One-sentence description]
[Time remaining if applicable]
```

Example:
```
⚠️ Monsoon Warning
Heavy rainfall expected in 30 days.
River-adjacent tracks at risk.
```

## Satirical Corporation Naming

The satirical names (Amdani, Amboney, Tota, Mahendra) are systemic satire:
- The joke is about **incentives and monopolies**
- The joke is NOT about real people or communities
- Keep descriptions focused on corporate behavior

Example:
```
Amdani Rail
An aggressive conglomerate that builds cheap,
operates loud, and buys everything in sight.

Starting Bonus: -15% construction cost
AI Behavior: Undercuts routes, controls ports,
 volume over quality.
```

## Word Choice

| Use | Avoid |
|-----|-------|
| Workers | Natives, coolies |
| Population | Savages |
| Rebellion | Mutiny (unless historical quote) |
| Administration | Regime (value-laden) |
| Contract | Order (imperative) |
| Revenue | Loot (unless pirate context) |
| Route | Territory (imperial) |

## Localization Notes

- Use ₹ (Indian Rupee) for currency
- Use metric tons for cargo
- Use kilometers for distance
- Date format: Month Year (e.g., "March 1858")
- Avoid British imperial units unless historically quoting

## Review Process

Before any player-facing text is finalized:
1. Check against `historical_cultural_review.md`
2. Verify clarity: can a non-historian understand it?
3. Verify tone: is it strategic, not sensational?
4. Verify agency: does the player have meaningful choices?
5. Verify specificity: are numbers and effects clear?
