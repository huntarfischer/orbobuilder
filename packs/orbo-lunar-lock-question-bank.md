# Orbo Lunar Lock — Coded Question Bank

This file contains the **actual Lunar Lock questions**.

There are **24 authored questions**:
- 12 possible Moon houses
- 2 independent questions for each house

Each question is a deterministic structural test. It does **not** award personality points. A confirmed answer returns a candidate `moonHouse`.

Orbo should calculate which Moon houses are possible from the surviving Ascendant/time candidates, ask only the relevant house questions, and compare the resulting Moon-house tumbler with the independently selected chart-ruler/Ascendant tumbler.

```json
{
  "id": "orbo_lunar_lock_v1",
  "version": "1.0.0",
  "purpose": "Resolve the Moon's candidate whole-sign house as a structural tumbler in birth-time rectification.",
  "runtime_rule": {
    "candidate_generation": "For every viable Ascendant candidate, calculate the Moon's whole-sign house for that candidate time.",
    "selection": "Ask Lunar Lock questions only for Moon houses represented by viable Ascendant candidates.",
    "max_options_note": "These are house-confirmation questions, so each question uses four response states rather than presenting all twelve houses at once.",
    "lock_rule": "A Moon house is lunar-locked when both authored questions for that house return confirm_target_house. One confirm plus one retain may be kept as a provisional lunar result. Any reject prevents a hard Lunar Lock for that house.",
    "pairing_rule": "Compare the resolved Moon house against the Moon house produced by the Ascendant candidate independently selected by the chart-ruler-in-house question. If they describe the same candidate chart, the rising-sign tumbler locks.",
    "no_numeric_scoring": true
  },
  "response_options": [
    {
      "id": "yes_clear",
      "text": "Yes — this is one of the clearest recurring patterns in my life.",
      "outcome": "confirm_target_house"
    },
    {
      "id": "sometimes",
      "text": "Sometimes — it fits, but not strongly enough to define the pattern.",
      "outcome": "retain_target_house"
    },
    {
      "id": "no",
      "text": "No — this is not especially characteristic of my experience.",
      "outcome": "reject_target_house"
    },
    {
      "id": "unknown",
      "text": "I'm not sure.",
      "outcome": "unresolved"
    }
  ],
  "houses": [
    {
      "house": 1,
      "label": "Moon in the 1st House",
      "kernel": "Emotional experience is immediate, embodied, personal, and responsive to the surrounding environment.",
      "questions": [
        {
          "id": "moon_h01_q1",
          "targetMoonHouse": 1,
          "question": "When something emotionally important happens, does it tend to register immediately in your body, mood, or sense of self before you have much distance from it?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 1
            }
          }
        },
        {
          "id": "moon_h01_q2",
          "targetMoonHouse": 1,
          "question": "When you are unsettled, is your first need usually to get yourself physically or emotionally settled — changing your surroundings, resting, eating, moving, or otherwise tending directly to your own state?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 1
            }
          }
        }
      ]
    },
    {
      "house": 2,
      "label": "Moon in the 2nd House",
      "kernel": "Emotional security is closely tied to stability, resources, continuity, self-support, and having enough.",
      "questions": [
        {
          "id": "moon_h02_q1",
          "targetMoonHouse": 2,
          "question": "When life feels uncertain, do money, resources, possessions, or the question of whether you have enough tend to become emotionally important very quickly?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 2
            }
          }
        },
        {
          "id": "moon_h02_q2",
          "targetMoonHouse": 2,
          "question": "When you need to feel steady again, does it help most to make things concrete — checking what you have, protecting what matters, restoring financial or material order, or returning to something dependable?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 2
            }
          }
        }
      ]
    },
    {
      "house": 3,
      "label": "Moon in the 3rd House",
      "kernel": "Feelings are processed through language, observation, movement, siblings or peers, and the immediate environment.",
      "questions": [
        {
          "id": "moon_h03_q1",
          "targetMoonHouse": 3,
          "question": "When something affects you strongly, do you usually need to talk about it, name it, write it down, or exchange information before you fully understand how you feel?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 3
            }
          }
        },
        {
          "id": "moon_h03_q2",
          "targetMoonHouse": 3,
          "question": "When you are emotionally stuck, does movement through your familiar world — a conversation, drive, walk, message exchange, sibling or peer contact — often help you regain your footing?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 3
            }
          }
        }
      ]
    },
    {
      "house": 4,
      "label": "Moon in the 4th House",
      "kernel": "Emotional gravity gathers around home, roots, family, ancestry, memory, privacy, and belonging.",
      "questions": [
        {
          "id": "moon_h04_q1",
          "targetMoonHouse": 4,
          "question": "Do home, family, ancestry, where you come from, or the condition of your private life tend to affect you more deeply than most people around you may realize?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 4
            }
          }
        },
        {
          "id": "moon_h04_q2",
          "targetMoonHouse": 4,
          "question": "When you need to recover emotionally, is your strongest instinct to return to a private base — home, family or chosen family, familiar surroundings, memory, or simply a place where you do not have to perform?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 4
            }
          }
        }
      ]
    },
    {
      "house": 5,
      "label": "Moon in the 5th House",
      "kernel": "Feelings seek expression through creativity, pleasure, romance, play, children, performance, and cherished creations.",
      "questions": [
        {
          "id": "moon_h05_q1",
          "targetMoonHouse": 5,
          "question": "Do romance, creativity, children, performance, play, or something you have personally made tend to become emotionally central rather than remaining just hobbies or pleasures?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 5
            }
          }
        },
        {
          "id": "moon_h05_q2",
          "targetMoonHouse": 5,
          "question": "When you feel depleted, do you recover most naturally by creating, playing, flirting, performing, spending time with children, making something, or returning to something that gives you genuine delight?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 5
            }
          }
        }
      ]
    },
    {
      "house": 6,
      "label": "Moon in the 6th House",
      "kernel": "Emotional equilibrium is tied to work, service, routines, health, maintenance, usefulness, and practical problem-solving.",
      "questions": [
        {
          "id": "moon_h06_q1",
          "targetMoonHouse": 6,
          "question": "Do work, responsibilities, health, routines, practical problems, or being useful to other people occupy a large amount of your emotional attention, even when you would rather switch off?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 6
            }
          }
        },
        {
          "id": "moon_h06_q2",
          "targetMoonHouse": 6,
          "question": "When you are upset, do you often feel better once you can do something useful — organize the details, clean up a problem, establish a routine, work, help, repair, or take care of what needs attention?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 6
            }
          }
        }
      ]
    },
    {
      "house": 7,
      "label": "Moon in the 7th House",
      "kernel": "Feelings become especially consequential through partnership, reciprocity, conflict, attachment, and one-to-one relationship.",
      "questions": [
        {
          "id": "moon_h07_q1",
          "targetMoonHouse": 7,
          "question": "Do close relationships have an unusually strong effect on your inner state, to the point that you often understand what you are feeling more clearly through another person's response to you?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 7
            }
          }
        },
        {
          "id": "moon_h07_q2",
          "targetMoonHouse": 7,
          "question": "When you are emotionally unsettled by a relationship, is it difficult to feel fully settled again until you know where you stand with the other person or some form of reciprocity has been restored?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 7
            }
          }
        }
      ]
    },
    {
      "house": 8,
      "label": "Moon in the 8th House",
      "kernel": "Emotional intensity gathers around vulnerability, trust, dependence, loss, shared resources, obligation, and consequential entanglement.",
      "questions": [
        {
          "id": "moon_h08_q1",
          "targetMoonHouse": 8,
          "question": "Do situations involving trust, loss, dependency, shared money, debt, inheritance, secrets, or obligations to other people tend to affect you with unusual emotional intensity?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 8
            }
          }
        },
        {
          "id": "moon_h08_q2",
          "targetMoonHouse": 8,
          "question": "When something feels emotionally dangerous or uncertain, do you instinctively need to understand what is really at stake — who depends on whom, what is shared, what could be lost, or what obligation exists beneath the surface?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 8
            }
          }
        }
      ]
    },
    {
      "house": 9,
      "label": "Moon in the 9th House",
      "kernel": "Feelings seek orientation through meaning, belief, philosophy, spirituality, teaching, higher learning, travel, and larger frameworks.",
      "questions": [
        {
          "id": "moon_h09_q1",
          "targetMoonHouse": 9,
          "question": "When life affects you deeply, do you tend to ask what it means, what larger pattern it belongs to, or how it changes what you believe about life?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 9
            }
          }
        },
        {
          "id": "moon_h09_q2",
          "targetMoonHouse": 9,
          "question": "When you feel emotionally lost, do you often recover through a larger frame — study, philosophy, spirituality, religion, divination, teaching, travel, or encountering an idea that puts the immediate experience into perspective?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 9
            }
          }
        }
      ]
    },
    {
      "house": 10,
      "label": "Moon in the 10th House",
      "kernel": "Emotional investment gathers around vocation, public life, responsibility, reputation, achievement, authority, and visible contribution.",
      "questions": [
        {
          "id": "moon_h10_q1",
          "targetMoonHouse": 10,
          "question": "Does the question of what you are doing with your life in the world — your work, calling, reputation, achievement, responsibility, or public contribution — affect you on a deeply personal level?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 10
            }
          }
        },
        {
          "id": "moon_h10_q2",
          "targetMoonHouse": 10,
          "question": "When you feel emotionally unmoored, does regaining a sense of purpose, competence, direction, or responsibility often help you feel like yourself again?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 10
            }
          }
        }
      ]
    },
    {
      "house": 11,
      "label": "Moon in the 11th House",
      "kernel": "Emotional belonging is sought through friendship, community, alliances, networks, shared hopes, causes, and the future.",
      "questions": [
        {
          "id": "moon_h11_q1",
          "targetMoonHouse": 11,
          "question": "Do friendships, communities, collaborators, groups, shared causes, or the feeling that you belong to something larger than yourself carry unusually strong emotional importance for you?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 11
            }
          }
        },
        {
          "id": "moon_h11_q2",
          "targetMoonHouse": 11,
          "question": "When you are discouraged, do you often recover through friends, community, collaboration, shared plans, or reconnecting with a future you still want to help build?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 11
            }
          }
        }
      ]
    },
    {
      "house": 12,
      "label": "Moon in the 12th House",
      "kernel": "Emotional life is strongly private and may gather around solitude, retreat, dreams, hidden burdens, grief, confinement, or difficult-to-name inner experience.",
      "questions": [
        {
          "id": "moon_h12_q1",
          "targetMoonHouse": 12,
          "question": "Do some of your strongest feelings happen away from other people, where solitude, dreams, grief, private burdens, or things that are difficult to explain can take on a life of their own?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 12
            }
          }
        },
        {
          "id": "moon_h12_q2",
          "targetMoonHouse": 12,
          "question": "When you are overwhelmed, is your strongest instinct often to withdraw for a while — sleeping, disappearing into privacy, retreating, reflecting, praying, dreaming, or otherwise stepping outside ordinary demands until you can hear yourself again?",
          "optionsRef": "response_options",
          "onConfirm": {
            "returns": {
              "moonHouse": 12
            }
          }
        }
      ]
    }
  ]
}
```

## Minimal runtime interpretation

```text
Both questions CONFIRM the same Moon house
→ HARD LUNAR LOCK

One CONFIRM + one RETAIN
→ PROVISIONAL LUNAR HOUSE

Any REJECT
→ no hard lock for that Moon house

Then:

resolved Moon house
+
ruler-house-selected Ascendant candidate
+
computed Moon house of that Ascendant candidate
=
if all structurally agree → RISING SIGN LOCK
```

The houses do **not** need to have the same number as the ruler house.

Example:

```text
Lunar Lock → Moon in 4H
Ruler question → Scorpio rising / Mars in 7H
Computed Scorpio candidate → Moon in 4H

Result → LOCK ON SCORPIO
```
