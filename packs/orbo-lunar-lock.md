# Orbo Rectification Layer: Lunar Lock

## Purpose

The **Lunar Lock** is an early structural rectification layer used immediately after Orbo asks whether the user knows the broad time of day of birth.

It is not primarily a personality score. It is a **tumbler in a combination lock**.

For every viable Ascendant candidate, Orbo calculates the Moon's whole-sign house. The user's Lunar Lock answer therefore resolves to a structural statement such as:

> **Moon in the 7th house**

The ruler-house rectification question independently resolves to a candidate such as:

> **Cancer rising, with its ruler in the 7th house**

If the Ascendant candidate selected by the ruler-house question also produces the Moon house selected by the Lunar Lock, the two tumblers agree and Orbo has a **rising-sign lock**.

---

## 1. Position in the Rectification Sequence

```text
Birth date + location
        ↓
TIME-OF-DAY QUESTION
Morning / daytime / night / unknown
        ↓
LUNAR LOCK
Which candidate Moon house matches lived experience?
        ↓
RULER-HOUSE LOCK
Which candidate Ascendant + chart-ruler house matches lived experience?
        ↓
RISING-SIGN LOCK
Lunar answer and ruler-house answer identify the same candidate
        ↓
DECAN
Which 10° third of the rising sign?
        ↓
SABIAN
Which degree-level psychological operation?
        ↓
rAsc
```

The two structural questions operate from different planetary perspectives:

- **Moon house:** Where experience becomes personal, habitual, emotionally consequential, protective, familiar, or vulnerable.
- **Chart ruler house:** Where the chart's governing principle is directed and where the life tends to organize itself.

---

## 2. Runtime Principle

For each viable Ascendant candidate:

```text
candidate Ascendant
        +
Moon's actual zodiac sign
        ↓
Moon's whole-sign house
```

Example, if the Moon remains in Aquarius throughout the relevant birth window:

| Candidate Ascendant | Aquarius Moon |
|---|---:|
| Aquarius | 1st house |
| Capricorn | 2nd house |
| Sagittarius | 3rd house |
| Scorpio | 4th house |
| Libra | 5th house |
| Virgo | 6th house |
| Leo | 7th house |
| Cancer | 8th house |
| Gemini | 9th house |
| Taurus | 10th house |
| Aries | 11th house |
| Pisces | 12th house |

Orbo does **not** ask about all twelve. It retrieves only the Moon-house answers corresponding to the currently viable Ascendant candidates, with a maximum of four options shown at once.

---

## 3. What Counts as a Lock

The Lunar Lock returns a house:

```json
{
  "moonHouse": 7
}
```

The ruler-house layer returns an Ascendant candidate and its ruler-house configuration:

```json
{
  "ascendant": "cancer",
  "ruler": "moon",
  "rulerHouse": 7
}
```

Orbo already knows the computed structure of that candidate:

```json
{
  "ascendant": "cancer",
  "moonHouse": 7,
  "rulerHouse": 7
}
```

So:

```text
Lunar tumbler: Moon in 7H
        +
Ruler tumbler: Cancer rising / ruler in 7H
        ↓
Cancer candidate actually has Moon in 7H
        ↓
LOCK
```

### Important

The two house numbers do **not** need to be identical.

Example:

```text
Lunar answer: Moon in 4H
Ruler answer: Scorpio rising / Mars in 7H
Computed Scorpio candidate: Moon 4H, Mars 7H
Result: LOCK ON SCORPIO
```

The rule is:

> **Does the Ascendant candidate selected by the ruler-house question produce the Moon house selected by the Lunar Lock?**

---

# 4. Two Lunar Question Families

Each Moon house receives two independently authored answer statements. They belong to two universal prompts.

## Question A — Emotional Gravity

> **Where does life tend to become most personally or emotionally consequential for you?**

This asks where emotional gravity gathers.

## Question B — Emotional Regulation

> **When you feel unsettled, what most often helps you regain a sense of emotional footing?**

This asks where the Moon seeks familiarity, regulation, safety, or restoration.

For any set of viable Ascendant candidates, Orbo retrieves only the answer statements associated with their candidate Moon houses.

---

# 5. Lunar Lock Question Bank

## Moon in the 1st House

**Meaning:** The Moon is brought directly to body, temperament, identity, appearance, and immediate experience. Feelings arrive personally and often visibly.

**Question A answer:**  
**My own state.** What happens tends to register immediately in my mood, body, or sense of self, and it can be difficult to separate how I feel from how I am experiencing the moment.

**Returns:** `moon_house_1`

**Question B answer:**  
**Getting myself physically and emotionally settled.** I recover by tending to my own state first: my body, surroundings, comfort, rhythm, or immediate needs.

**Returns:** `moon_house_1`

---

## Moon in the 2nd House

**Meaning:** The Moon seeks continuity through resources, material stability, possessions, skills, self-support, and having enough.

**Question A answer:**  
**Security and what I can rely on.** Money, resources, possessions, stability, or knowing that I have enough can carry more emotional weight for me than they may appear to from the outside.

**Returns:** `moon_house_2`

**Question B answer:**  
**Restoring a sense of stability.** I feel better when I can make things concrete: check what resources are available, protect what matters, establish a dependable plan, or return to something familiar and reliable.

**Returns:** `moon_house_2`

---

## Moon in the 3rd House

**Meaning:** The Moon processes experience through conversation, language, siblings or peers, local movement, information, familiar places, and everyday exchange.

**Question A answer:**  
**The everyday world around me.** Conversations, messages, siblings or peers, familiar places, and what is happening nearby can strongly affect how I feel and how I understand an experience.

**Returns:** `moon_house_3`

**Question B answer:**  
**Talking, thinking, or moving through it.** I often regain my footing by putting feelings into words, exchanging information, taking a drive or walk, or reconnecting with the familiar world around me.

**Returns:** `moon_house_3`

---

## Moon in the 4th House

**Meaning:** The Moon is rooted in home, family, ancestry, memory, private life, land, belonging, and the need for an interior base.

**Question A answer:**  
**Home, family, roots, and private life.** Where I belong, where I come from, and what happens inside the private part of my life can affect me more deeply than what is visible publicly.

**Returns:** `moon_house_4`

**Question B answer:**  
**Returning to my base.** I recover through privacy, home, family or chosen family, familiar surroundings, memory, or simply having a protected place where I do not have to perform for anyone.

**Returns:** `moon_house_4`

---

## Moon in the 5th House

**Meaning:** The Moon seeks emotional vitality through creation, play, pleasure, romance, children, performance, risk, affection, and personally cherished expressions.

**Question A answer:**  
**What I love and bring to life.** Creativity, romance, pleasure, children, performance, play, or something I have personally made can become emotionally central very quickly.

**Returns:** `moon_house_5`

**Question B answer:**  
**Expressing or creating something.** I regain myself through play, affection, romance, art, entertainment, making something, or spending time with people or projects that awaken genuine delight.

**Returns:** `moon_house_5`

---

## Moon in the 6th House

**Meaning:** The Moon becomes involved in work, service, obligation, maintenance, health, routines, craft, problem-solving, and repeated tasks that keep life functioning.

**Question A answer:**  
**What needs to be taken care of.** Work, responsibilities, health, routines, practical problems, or being useful to other people can occupy a surprising amount of my emotional attention.

**Returns:** `moon_house_6`

**Question B answer:**  
**Doing what needs to be done.** I often feel steadier once I can establish a routine, solve the practical problem, clean something up, organize the details, work, or make myself useful.

**Returns:** `moon_house_6`

---

## Moon in the 7th House

**Meaning:** The Moon encounters itself through significant others. Partnership, attachment, reciprocity, interpersonal response, conflict, negotiation, and being emotionally witnessed become major sites of lived experience.

**Question A answer:**  
**My close relationships.** What happens between me and another person can affect my internal state profoundly; I often understand what I am feeling more clearly through partnership or one-to-one interaction.

**Returns:** `moon_house_7`

**Question B answer:**  
**Re-establishing connection or relational clarity.** I tend to feel steadier once I know where I stand with the important person involved, have talked it through, or restored some form of reciprocity.

**Returns:** `moon_house_7`

---

## Moon in the 8th House

**Meaning:** The Moon becomes emotionally engaged with shared stakes: dependence, trust, loss, debt, inheritance, other people's resources, vulnerability, fear, obligation, and entanglement.

**Question A answer:**  
**What is shared, vulnerable, or difficult to control alone.** Trust, loss, dependency, obligations, shared money, secrets, or deeply consequential entanglements can carry enormous emotional weight for me.

**Returns:** `moon_house_8`

**Question B answer:**  
**Understanding what is really at stake.** I regain my footing by getting beneath the surface: clarifying the trust involved, the obligation, the shared resources, the risk, or what I may have to surrender or depend upon.

**Returns:** `moon_house_8`

---

## Moon in the 9th House

**Meaning:** The Moon seeks emotional orientation through worldview, religion, philosophy, divination, higher learning, teaching, foreign places, long journeys, law, interpretation, and meaning.

**Question A answer:**  
**What an experience means.** Beliefs, philosophy, spirituality, learning, travel, or finding the larger pattern behind events can become emotionally important to me, especially when life stops making sense.

**Returns:** `moon_house_9`

**Question B answer:**  
**Finding a larger frame.** I regain perspective by learning, reading, studying, traveling, consulting a belief system, or asking how the immediate experience fits into a much larger story.

**Returns:** `moon_house_9`

---

## Moon in the 10th House

**Meaning:** The Moon becomes emotionally invested in public life, vocation, responsibility, authority, reputation, achievement, visibility, and one's effect on the larger world.

**Question A answer:**  
**What I am doing with my life in the world.** Work, calling, achievement, reputation, responsibility, or whether I am making a meaningful public contribution can affect me on a deeply personal level.

**Returns:** `moon_house_10`

**Question B answer:**  
**Regaining direction and competence.** I often feel steadier when I can identify what I am responsible for, make progress toward a goal, restore my sense of purpose, or know what role I am meant to play.

**Returns:** `moon_house_10`

---

## Moon in the 11th House

**Meaning:** The Moon seeks belonging through friends, alliances, communities, groups, networks, patrons, shared causes, hopes, and the future.

**Question A answer:**  
**My people and the future we are moving toward.** Friendship, community, groups, collaborators, shared causes, and whether I feel included in something larger than myself can matter to me enormously.

**Returns:** `moon_house_11`

**Question B answer:**  
**Reconnecting with people and possibility.** I regain emotional footing through friends, community, collaboration, shared plans, or remembering that I am part of a future larger than the immediate problem.

**Returns:** `moon_house_11`

---

## Moon in the 12th House

**Meaning:** The Moon withdraws from direct visibility. Emotional experience may collect around solitude, retreat, hidden burdens, dreams, confinement, private grief, inaccessible feelings, or spiritual interiority.

**Question A answer:**  
**The part of life I experience privately.** Some of my strongest feelings happen away from other people, and solitude, hidden burdens, dreams, grief, retreat, or things I cannot easily explain can carry unusual emotional force.

**Returns:** `moon_house_12`

**Question B answer:**  
**Having enough protected space to disappear for a while.** I often recover through solitude, sleep, retreat, privacy, spiritual reflection, or temporarily stepping outside ordinary demands until I can hear myself again.

**Returns:** `moon_house_12`

---

# 6. Runtime Assembly

The bank can store two universal prompts and two answer variants per house.

```json
{
  "lunarLock": {
    "questionA": {
      "id": "lunar_gravity",
      "prompt": "Where does life tend to become most personally or emotionally consequential for you?"
    },
    "questionB": {
      "id": "lunar_regulation",
      "prompt": "When you feel unsettled, what most often helps you regain a sense of emotional footing?"
    }
  }
}
```

Each house supplies its own answer text:

```json
{
  "house": 7,
  "answers": {
    "lunar_gravity": "My close relationships...",
    "lunar_regulation": "Re-establishing connection or relational clarity..."
  }
}
```

Runtime sketch:

```js
const viableMoonHouses = unique(
  candidateAscendants.map(candidate => candidate.moonHouse)
);

const options = viableMoonHouses.map(
  house => lunarBank[house].answers[currentQuestion]
);
```

---

# 7. Example Question Assembly

Assume the surviving candidates produce:

```text
Candidate A → Moon 4H
Candidate B → Moon 6H
Candidate C → Moon 7H
Candidate D → Moon 9H
```

Orbo asks:

> **Where does life tend to become most personally or emotionally consequential for you?**

A. Home, family, roots, and private life.  
`→ Moon 4H`

B. What needs to be taken care of: work, health, routines, obligations, usefulness.  
`→ Moon 6H`

C. My close relationships and knowing where I stand with another person.  
`→ Moon 7H`

D. What an experience means and how it fits into a larger worldview.  
`→ Moon 9H`

The user never sees the house labels.

---

# 8. Using the Two Lunar Questions

The two questions provide two independent turns of the same Lunar tumbler.

## Confirmed Lunar result

```text
Question A → Moon 7H
Question B → Moon 7H
```

```json
{
  "lunarHouse": 7,
  "lunarState": "confirmed"
}
```

## Split Lunar result

```text
Question A → Moon 7H
Question B → Moon 4H
```

```json
{
  "lunarCandidates": [7, 4],
  "lunarState": "split"
}
```

A split is not an error. The ruler-house tumbler can resolve it.

Orbo may either:

1. ask both Lunar questions routinely; or
2. ask Question A first and use Question B only when the lock remains ambiguous.

The data structure supports either behavior.

---

# 9. Structural Lock Logic

Each viable candidate should already know:

```json
{
  "id": "leo_candidate",
  "ascendant": "leo",
  "moonHouse": 7,
  "chartRuler": "sun",
  "rulerHouse": 9
}
```

If the user selects:

```text
Lunar Lock → Moon 7H
Ruler Lock → Leo rising / Sun 9H
```

and the computed Leo candidate is:

```text
Leo rising → Moon 7H + Sun 9H
```

then:

```text
LUNAR TUMBLER MATCH
+
RULER TUMBLER MATCH
=
LEO RISING LOCK
```

Pseudocode:

```js
const lunarMatches = candidates.filter(
  c => lunarAnswers.includes(c.moonHouse)
);

const rulerMatches = candidates.filter(
  c => c.id === rulerAnswer.candidateId
);

const locked = intersection(lunarMatches, rulerMatches);

if (locked.length === 1) {
  return {
    status: "LOCKED",
    ascendant: locked[0].ascendant
  };
}
```

---

# 10. Cancer Rising and Correlated Evidence

Cancer is a special case because the Moon is itself the chart ruler.

Example, Moon in Capricorn:

```text
Cancer rising
→ Capricorn = 7th house
→ Moon = 7th-house Moon
→ chart ruler Moon = 7th house
```

The two questions may return:

```text
Lunar Lock: Moon in 7H
Ruler Lock: Cancer rising / ruler in 7H
```

This is a very clean lock, but the evidence is astrologically correlated because both questions describe the same planet.

Orbo may still use the agreement as a structural lock while marking:

```json
{
  "lunarAndRulerSamePlanet": true
}
```

If Orbo later uses confidence statistics, it should avoid pretending these are two fully independent observations.

---

# 11. Moon Sign Changes During the Birth Window

No separate system is required if the Moon changes signs.

Instead, each time-qualified candidate stores its actual Moon sign and resulting Moon house.

Example:

```json
[
  {
    "ascendant": "virgo",
    "moonSign": "gemini",
    "moonHouse": 10
  },
  {
    "ascendant": "virgo",
    "moonSign": "cancer",
    "moonHouse": 11
  }
]
```

The same twelve-house Lunar Lock bank still works.

---

# 12. Recommended House Record Shape

```json
{
  "house": 7,
  "name": "Moon in the 7th House",
  "kernel": {
    "function": "relate",
    "gravity": "partnership and significant others",
    "regulation": "reciprocity and relational clarity"
  },
  "questions": [
    {
      "id": "lunar_gravity",
      "answer": "My close relationships. What happens between me and another person can affect my internal state profoundly; I often understand what I am feeling more clearly through partnership or one-to-one interaction.",
      "returns": { "moonHouse": 7 }
    },
    {
      "id": "lunar_regulation",
      "answer": "Re-establishing connection or relational clarity. I tend to feel steadier once I know where I stand with the important person involved, have talked it through, or restored some form of reciprocity.",
      "returns": { "moonHouse": 7 }
    }
  ]
}
```

---

# 13. Design Rules

1. **Every answer returns a house, not a personality score.**
2. **The universal prompts remain the same across houses.** This lets Orbo assemble candidate-specific questions without AI.
3. **Every option must be psychologically plausible.** Avoid a flattering answer surrounded by dysfunction.
4. **Do not expose house numbers during rectification.**
5. **Do not show astrological terminology in user-facing option text.**
6. **Use concrete lived domains:** home, work, relationship, resources, community, meaning, privacy, etc.
7. **Question A and Question B approach the same house from different directions.** A asks where emotional consequence gathers; B asks how emotional equilibrium is restored.
8. **A split answer preserves ambiguity rather than forcing a score.**
9. **Only viable astronomical candidates contribute answer options.**
10. **A rising-sign lock occurs when the Lunar tumbler and ruler-house tumbler identify the same Ascendant candidate.**

---

# 14. Combination Lock Model

```text
┌────────────────────────────────────────────┐
│ TUMBLER 0 — REMEMBERED TIME               │
│ Morning / daytime / night / unknown       │
└────────────────────────────────────────────┘
                     ↓
┌────────────────────────────────────────────┐
│ TUMBLER 1 — LUNAR LOCK                    │
│ Which Moon house matches lived experience?│
└────────────────────────────────────────────┘
                     ↓
┌────────────────────────────────────────────┐
│ TUMBLER 2 — RULER LOCK                    │
│ Which Ascendant + ruler house matches?    │
└────────────────────────────────────────────┘
                     ↓
             RISING SIGN LOCK
                     ↓
┌────────────────────────────────────────────┐
│ TUMBLER 3 — DECAN                         │
│ Which third of the 30° sign?              │
└────────────────────────────────────────────┘
                     ↓
               10° WINDOW
                     ↓
┌────────────────────────────────────────────┐
│ TUMBLER 4 — SABIAN                        │
│ Which degree-level operation?             │
└────────────────────────────────────────────┘
                     ↓
                    rAsc
```

The conceptual shift is important:

> **Orbo is not accumulating a pile of vaguely supportive personality scores. It is trying combinations.**

Each answer turns a tumbler to a specific astrological state. When independently derived states point to the same candidate chart, the mechanism clicks into place.

---

# 15. Dataset Size

The core Lunar Lock requires only:

```text
12 Moon-house kernels
×
2 answer statements each
=
24 authored Lunar answer statements
```

At runtime Orbo:

1. calculates the Moon house for every viable Ascendant candidate;
2. retrieves only those house answers;
3. presents no more than four options at a time;
4. converts the selected option directly into a Moon-house result;
5. uses the second Lunar question as confirmation or tie-preservation;
6. compares the Lunar result with the candidate selected by the ruler-house question;
7. locks the rising sign when both tumblers identify the same candidate;
8. passes that rising sign to the decan layer;
9. passes the chosen decan to the Sabian degree-resolution layer.

```text
LUNAR LOCK → RULER LOCK → DECAN → SABIAN → rAsc
```
