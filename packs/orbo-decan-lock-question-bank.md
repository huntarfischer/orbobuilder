# Orbo Decan Lock — Coded Question Bank

## Purpose

This is the pre-authored **middle tumbler** of Orbo's rAsc rectification system.

It is used **after the rising sign has been structurally locked** by the Lunar Lock + chart-ruler/house process and **before Sabian degree fine-tuning**.

Each rising sign has:

- **3 possible decans**
- **2 independent three-way discriminator questions**
- a fourth `unresolved` option so Orbo never forces a false choice
- deterministic returns of `decan: 1`, `2`, or `3`

The questions are based on the supplied *Thirty-Six Decans in Whole-Sign Astrology* report. The source distinguishes the first, second, and third decans as exact ten-degree divisions and treats the classical Western face ruler as the default traditional ruler while preserving other ruler systems as separate alternatives.

## Lock logic

```text
RISING SIGN LOCKED
        ↓
Decan Question 1
        ↓
returns 1 / 2 / 3 / unresolved
        ↓
Decan Question 2
        ↓
returns 1 / 2 / 3 / unresolved
        ↓
same non-null result twice
        ↓
DECAN LOCK
        ↓
1 → 0°00′–9°59′59″
2 → 10°00′–19°59′59″
3 → 20°00′–29°59′59″
        ↓
SABIAN FINE-TUNING
```

The questions do not show the user the decan number, degree range, ruler, or astrological keywords.

```json
{
  "id": "orbo_decan_lock_v1",
  "version": "1.0.0",
  "sourceBasis": {
    "description": "Question language is derived from the supplied Thirty-Six Decans report. The report treats the classical Western face ruler as the default traditional ruler and the triplicity/decan ruler as a separately labeled alternative.",
    "decanRanges": {
      "1": "0°00′00″–9°59′59″",
      "2": "10°00′00″–19°59′59″",
      "3": "20°00′00″–29°59′59″"
    }
  },
  "purpose": "After the rising sign is structurally locked, discriminate which ten-degree decan contains rAsc.",
  "runtime": {
    "input": "locked rising sign",
    "questionCountPerSign": 2,
    "answersPerQuestion": 4,
    "hardLock": "If both questions return the same non-null decan, lock that decan.",
    "splitResult": "If the two questions return different decans, preserve both as unresolved and do not force a decan.",
    "unresolved": "A null answer leaves the question non-discriminating.",
    "output": {
      "decan": "1 | 2 | 3",
      "degreeWindow": "derived from decan"
    }
  },
  "signs": [
    {
      "sign": "Aries",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Mars",
          "alternativeRuler": "Mars",
          "keywords": [
            "initiative",
            "confrontation",
            "autonomy",
            "urgency",
            "courage",
            "dominion"
          ],
          "kernel": "Moves by initiating, confronting, and establishing autonomy through direct action."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Sun",
          "alternativeRuler": "Sun",
          "keywords": [
            "leadership",
            "visibility",
            "confidence",
            "establishment",
            "ambition",
            "self-definition"
          ],
          "kernel": "Moves by establishing a visible position, authorship, leadership, and personal authority."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Venus",
          "alternativeRuler": "Jupiter",
          "keywords": [
            "completion",
            "alliance",
            "celebration",
            "creativity",
            "desire",
            "consolidation"
          ],
          "kernel": "Moves by joining, completing, consolidating, and turning desire into a finished or shared result."
        }
      ],
      "questions": [
        {
          "id": "decan_aries_q1",
          "prompt": "When you enter a situation where nothing has been established yet, what is most natural for you?",
          "options": [
            {
              "text": "I move first. I would rather confront the situation directly, establish my independence, and create momentum through action.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I establish a position people can recognize. I want to define the direction, take authorship, and become a clear center of authority.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I look for what can be brought together. I want to turn the initial push into an alliance, completed undertaking, or something worth celebrating.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these is clearly more characteristic of me.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_aries_q2",
          "prompt": "When your will meets resistance, which response is most familiar?",
          "options": [
            {
              "text": "I push into the obstacle and find out what happens by engaging it directly.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I become more concerned with defining my position, taking command, and proving that I can carry the direction myself.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I become more concerned with securing cooperation, preserving what has already been won, or bringing the effort to a satisfying completion.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "It depends too much on the situation to choose one.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Taurus",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Mercury",
          "alternativeRuler": "Venus",
          "keywords": [
            "cultivation",
            "craft",
            "calculation",
            "embodiment",
            "productivity",
            "resourcefulness"
          ],
          "kernel": "Works matter through skill, cultivation, measurement, craft, and practical resourcefulness."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Moon",
          "alternativeRuler": "Mercury",
          "keywords": [
            "acquisition",
            "stewardship",
            "security",
            "exchange",
            "control",
            "material intelligence"
          ],
          "kernel": "Seeks security through acquiring, administering, exchanging, and controlling tangible resources."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Saturn",
          "alternativeRuler": "Saturn",
          "keywords": [
            "endurance",
            "preservation",
            "scarcity",
            "patience",
            "delayed harvest",
            "consolidation"
          ],
          "kernel": "Protects value through patience, preservation, endurance, and sustaining what must mature slowly."
        }
      ],
      "questions": [
        {
          "id": "decan_taurus_q1",
          "prompt": "When you are trying to make something materially secure, where does your attention go first?",
          "options": [
            {
              "text": "To the method: how it can be cultivated, built, measured, improved, or made more skillfully.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "To possession and stewardship: what resources are available, who controls them, and how they can be managed or exchanged reliably.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "To durability: what can survive limits, scarcity, delay, or pressure and still be worth preserving over time.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these stands out clearly.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_taurus_q2",
          "prompt": "Which kind of accomplishment gives you the deepest sense that something is truly solid?",
          "options": [
            {
              "text": "I have made or cultivated something tangible with real skill and practical usefulness.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I have secured access, resources, ownership, or a dependable system of exchange that I can actually rely on.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I have kept something valuable alive through a long period of difficulty and proved that it can endure.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "I cannot separate these enough to choose.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Gemini",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Jupiter",
          "alternativeRuler": "Mercury",
          "keywords": [
            "inquiry",
            "interpretation",
            "teaching",
            "multiplicity",
            "expansion",
            "restless thought"
          ],
          "kernel": "Expands through inquiry, interpretation, teaching, multiplicity, and following many lines of thought."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Mars",
          "alternativeRuler": "Venus",
          "keywords": [
            "debate",
            "tactical speech",
            "experimentation",
            "contradiction",
            "desire",
            "agitation"
          ],
          "kernel": "Tests ideas through debate, contradiction, tactical language, experimentation, and verbal friction."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Sun",
          "alternativeRuler": "Saturn/Uranus",
          "keywords": [
            "culmination",
            "exposure",
            "mental overload",
            "severance",
            "finality",
            "radical insight"
          ],
          "kernel": "Pushes complexity toward exposure, decisive insight, severance, or the end of an exhausted narrative."
        }
      ],
      "questions": [
        {
          "id": "decan_gemini_q1",
          "prompt": "When a subject really captures your mind, what do you tend to do with it?",
          "options": [
            {
              "text": "I open it outward: gather more perspectives, make connections, interpret it, and often want to explain or teach what I am finding.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I test it: argue with it, experiment, look for contradictions, and sharpen my thinking through friction or exchange.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I push it toward a decisive point: expose the underlying issue, identify what no longer works, and arrive at the conclusion or break that changes the whole picture.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "No one pattern is clearly dominant.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_gemini_q2",
          "prompt": "When you have too much information or too many possibilities, what usually happens?",
          "options": [
            {
              "text": "My mind keeps branching. I want to keep learning, comparing, connecting, and following the next interesting line of thought.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I become more argumentative or experimental. I need to test the competing ideas against each other to see what survives.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I reach a threshold where I need to cut through the excess, expose the decisive fact, and close or abandon part of the story.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "It varies too much to choose.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Cancer",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Venus",
          "alternativeRuler": "Moon",
          "keywords": [
            "affection",
            "hospitality",
            "attraction",
            "belonging",
            "protection",
            "fertility"
          ],
          "kernel": "Creates belonging through affection, hospitality, protection, attraction, and nurturing connection."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Mercury",
          "alternativeRuler": "Mars/Pluto",
          "keywords": [
            "emotional strategy",
            "negotiation",
            "concealment",
            "appetite",
            "rivalry",
            "resource exchange"
          ],
          "kernel": "Navigates emotional life strategically through negotiation, privacy, rivalry, appetite, and the exchange of resources."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Moon",
          "alternativeRuler": "Jupiter/Neptune",
          "keywords": [
            "memory",
            "saturation",
            "imagination",
            "kinship",
            "retreat",
            "emotional abundance"
          ],
          "kernel": "Absorbs experience through memory, atmosphere, kinship, imagination, emotional saturation, and retreat."
        }
      ],
      "questions": [
        {
          "id": "decan_cancer_q1",
          "prompt": "When you care deeply about a person, place, or situation, how does that care most naturally express itself?",
          "options": [
            {
              "text": "I create belonging: protect, feed, welcome, comfort, and make the bond feel safe and wanted.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I become strategic about the relationship: I notice what is being exchanged, what is unspoken, what each person needs, and how the emotional situation must be negotiated.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I absorb it deeply: memories, atmosphere, family feeling, longing, and imagination become part of the way I carry the bond inside me.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these is clearly primary.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_cancer_q2",
          "prompt": "When something threatens your sense of emotional security, what is your most familiar response?",
          "options": [
            {
              "text": "I move closer to what I love and try to restore safety, warmth, and belonging around it.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I read the room, keep some things private, and work out the emotional leverage, negotiation, or exchange needed to protect my position.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I retreat inward, into memory, family feeling, imagination, or a protected emotional world until I can process what has saturated me.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "The response depends too much on context.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Leo",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Saturn",
          "alternativeRuler": "Sun",
          "keywords": [
            "tested authority",
            "struggle",
            "endurance",
            "pride",
            "restraint",
            "contested sovereignty"
          ],
          "kernel": "Builds authority through resistance, endurance, restraint, and having sovereignty tested rather than simply granted."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Jupiter",
          "alternativeRuler": "Jupiter",
          "keywords": [
            "victory",
            "patronage",
            "confidence",
            "generosity",
            "recognition",
            "expansion"
          ],
          "kernel": "Expands authority through confidence, recognition, generosity, patronage, and a sense of honorable victory."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Mars",
          "alternativeRuler": "Mars",
          "keywords": [
            "valor",
            "performance",
            "defense",
            "competition",
            "persistence",
            "dramatic courage"
          ],
          "kernel": "Proves authority through performance, competition, defense, persistence, and visible acts of courage."
        }
      ],
      "questions": [
        {
          "id": "decan_leo_q1",
          "prompt": "When you find yourself in a visible role, what tends to define the experience for you?",
          "options": [
            {
              "text": "I feel that authority has to be earned. I become serious about proving that I can withstand resistance and carry the weight of the role.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I grow into the visibility. Recognition, encouragement, generosity, and helping others rise with me make me feel more capable and expansive.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I feel called to perform under pressure. Competition, advocacy, defense, or the need to demonstrate courage tends to bring out my strongest presence.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these clearly describes me.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_leo_q2",
          "prompt": "When your pride, authority, or creative work is challenged, what response is most familiar?",
          "options": [
            {
              "text": "I become more controlled and enduring. I want to prove that opposition cannot dislodge me.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I try to rise above the challenge through confidence, perspective, generosity, and a larger sense of what success can become.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I meet the challenge directly and visibly. I want to defend the work, compete well, and show courage through action.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "It varies too much to choose one.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Virgo",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Sun",
          "alternativeRuler": "Mercury",
          "keywords": [
            "prudence",
            "analysis",
            "cultivation",
            "competence",
            "service",
            "discernment"
          ],
          "kernel": "Improves through analysis, discernment, preparation, cultivation, competence, and careful service."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Venus",
          "alternativeRuler": "Saturn",
          "keywords": [
            "refinement",
            "preservation",
            "gain",
            "restraint",
            "craftsmanship",
            "selective value"
          ],
          "kernel": "Refines by selecting what is worth preserving, editing excess, practicing restraint, and improving quality through craft."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Mercury",
          "alternativeRuler": "Venus",
          "keywords": [
            "accounting",
            "completion",
            "articulation",
            "commerce",
            "classification",
            "practical intelligence"
          ],
          "kernel": "Completes by auditing, classifying, articulating, accounting, and translating complexity into usable form."
        }
      ],
      "questions": [
        {
          "id": "decan_virgo_q1",
          "prompt": "When you are handed something imperfect, what kind of improvement comes most naturally?",
          "options": [
            {
              "text": "I diagnose the problem and improve the method: analyze what is happening, prepare carefully, and make the process more competent.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I refine the thing itself: edit, preserve what is valuable, remove what is unnecessary, and improve its quality through careful selection.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I bring it to completion: organize the information, audit the details, classify what belongs where, and turn the work into a clear usable result.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "No one approach dominates.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_virgo_q2",
          "prompt": "What bothers you most when work is not yet right?",
          "options": [
            {
              "text": "The underlying method is inefficient, poorly prepared, or insufficiently thought through.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "The quality is uneven because no one has made the difficult choices about what should be kept, improved, or removed.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "The loose ends are still loose: the records, categories, language, accounts, or final organization have not been properly closed.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "These frustrate me about equally.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Libra",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Moon",
          "alternativeRuler": "Venus",
          "keywords": [
            "mediation",
            "reciprocity",
            "peace-making",
            "responsiveness",
            "equilibrium",
            "social intelligence"
          ],
          "kernel": "Restores balance through responsiveness, reciprocity, mediation, social sensitivity, and immediate peace-making."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Saturn",
          "alternativeRuler": "Saturn/Uranus",
          "keywords": [
            "judgment",
            "sorrow",
            "contract",
            "boundaries",
            "consequence",
            "structural fairness"
          ],
          "kernel": "Creates fairness through judgment, boundaries, contracts, accountability, and accepting the consequences of imbalance."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Jupiter",
          "alternativeRuler": "Mercury",
          "keywords": [
            "settlement",
            "counsel",
            "reconciliation",
            "law",
            "deliberation",
            "restorative balance"
          ],
          "kernel": "Seeks restorative settlement through counsel, deliberation, law, reasoned compromise, and reconciliation after conflict."
        }
      ],
      "questions": [
        {
          "id": "decan_libra_q1",
          "prompt": "When two people or sides are out of balance, what is your instinctive way of approaching the problem?",
          "options": [
            {
              "text": "I respond to the relationship itself: listen to both sides, restore reciprocity, and try to bring the emotional or social atmosphere back into balance.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I want the terms clarified: boundaries, obligations, consequences, and what a fair structure actually requires.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I want to deliberate toward a settlement: examine the arguments, advise, negotiate, and find terms that can genuinely resolve or repair the dispute.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these clearly comes first.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_libra_q2",
          "prompt": "What makes an agreement feel truly fair to you?",
          "options": [
            {
              "text": "Both sides feel seen and the relationship has regained genuine reciprocity rather than merely obeying a rule.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "The boundaries and responsibilities are explicit, enforceable, and able to withstand disappointment or conflict.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "The agreement reflects thoughtful counsel and gives the conflict somewhere constructive to go, rather than simply stopping it.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "I need all three equally.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Scorpio",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Mars",
          "alternativeRuler": "Mars/Pluto",
          "keywords": [
            "severance",
            "crisis",
            "appetite",
            "struggle",
            "penetration",
            "emotional intensity"
          ],
          "kernel": "Meets intensity by penetrating the core, confronting crisis, struggling directly, and severing what cannot continue."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Sun",
          "alternativeRuler": "Jupiter/Neptune",
          "keywords": [
            "pleasure",
            "regeneration",
            "loyalty",
            "revelation",
            "magnetism",
            "hidden vitality"
          ],
          "kernel": "Finds vitality through deep loyalty, revelation, magnetism, pleasure, and regeneration from hidden or intense experience."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Venus",
          "alternativeRuler": "Moon",
          "keywords": [
            "seduction",
            "fantasy",
            "attachment",
            "ambiguity",
            "intoxication",
            "emotional entanglement"
          ],
          "kernel": "Moves through intensity by attachment, attraction, fantasy, ambiguity, and emotionally entangling bonds."
        }
      ],
      "questions": [
        {
          "id": "decan_scorpio_q1",
          "prompt": "When you become deeply involved in something, what most often gives the involvement its intensity?",
          "options": [
            {
              "text": "I need to get to the core of it. Crisis, conflict, desire, or secrecy makes me more determined to penetrate the situation and decide what must continue or be cut away.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I feel more alive through depth itself. Loyalty, revelation, intimacy, pleasure, research, or recovering hidden vitality can become regenerative for me.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "The bond develops its own gravity. Attraction, attachment, fantasy, uncertainty, or emotional ambiguity can pull me further into the experience than I expected.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these is distinctly more familiar.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_scorpio_q2",
          "prompt": "When emotional stakes become very high, which pattern is most recognizable?",
          "options": [
            {
              "text": "I confront the underlying issue and, if necessary, make the hard cut rather than remain indefinitely in uncertainty.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I look for the hidden source of life in the situation: what can be revealed, renewed, trusted, or regenerated through going deeper.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I can remain bound to the complexity of the attachment itself, trying to understand what is desire, intuition, fantasy, loyalty, or entanglement.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "It depends too much on the relationship or situation.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Sagittarius",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Mercury",
          "alternativeRuler": "Jupiter",
          "keywords": [
            "speed",
            "travel",
            "publication",
            "inquiry",
            "persuasion",
            "rapid expansion"
          ],
          "kernel": "Expands by moving quickly, traveling, publishing, persuading, questioning, and distributing ideas."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Moon",
          "alternativeRuler": "Mars",
          "keywords": [
            "resilience",
            "vigilance",
            "defense",
            "instinct",
            "endurance",
            "emotional conviction"
          ],
          "kernel": "Holds meaning through resilience, vigilance, defense, instinct, endurance, and emotionally lived conviction."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Saturn",
          "alternativeRuler": "Sun",
          "keywords": [
            "burden",
            "doctrine",
            "authority",
            "culmination",
            "obligation",
            "ideological rigidity"
          ],
          "kernel": "Turns belief into doctrine, authority, obligation, institutional weight, and the burden of carrying a conviction to culmination."
        }
      ],
      "questions": [
        {
          "id": "decan_sagittarius_q1",
          "prompt": "When you become convinced that an idea matters, what do you most naturally do with it?",
          "options": [
            {
              "text": "I move it outward quickly: travel with it, publish it, teach it, argue for it, or connect it to new people and places.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I stand by it. The belief becomes something I protect through adversity, and its truth is tested by whether I can keep living from it under pressure.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I formalize it. I become concerned with the doctrine, standard, authority, institution, or long-term obligation that could carry the belief beyond the moment.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these is clearly strongest.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_sagittarius_q2",
          "prompt": "When your worldview is challenged, which response sounds most familiar?",
          "options": [
            {
              "text": "I go looking for more information, more territory, or a better argument and expand the field rather than stay pinned down.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I become vigilant and resilient. I hold the line around what experience has taught me and defend the conviction if necessary.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I become more serious about principles, obligations, and who has the authority to define or uphold the standard.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "My response is too situational to choose.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Capricorn",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Jupiter",
          "alternativeRuler": "Saturn",
          "keywords": [
            "strategic growth",
            "adaptation",
            "management",
            "exchange",
            "pragmatism",
            "opportunity"
          ],
          "kernel": "Advances through strategic adaptation, management, exchange, pragmatism, and recognizing opportunity within constraints."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Mars",
          "alternativeRuler": "Venus",
          "keywords": [
            "labor",
            "construction",
            "ambition",
            "craft",
            "disciplined desire",
            "material contest"
          ],
          "kernel": "Advances through disciplined labor, construction, craft, ambition, material effort, and competitive building."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Sun",
          "alternativeRuler": "Mercury",
          "keywords": [
            "governance",
            "consolidation",
            "executive power",
            "status",
            "calculation",
            "material command"
          ],
          "kernel": "Advances through governance, executive calculation, consolidation, status, administration, and command of material systems."
        }
      ],
      "questions": [
        {
          "id": "decan_capricorn_q1",
          "prompt": "When you are pursuing a serious long-term goal, what kind of strategy feels most natural?",
          "options": [
            {
              "text": "I adapt strategically: read the opportunity, manage changing conditions, negotiate exchanges, and find the practical route that allows growth inside real constraints.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I build it through disciplined effort. I expect labor, craft, competition, and repetition to turn ambition into something material.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I organize the whole system. I want control of the decisions, resources, calculations, and structure needed to consolidate the result and make it durable.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "I use all three too evenly to choose.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_capricorn_q2",
          "prompt": "When a major objective becomes difficult, which response is most familiar?",
          "options": [
            {
              "text": "I change the strategy without abandoning the objective, looking for a more advantageous arrangement of constraints and opportunities.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I put more disciplined effort into the build itself and focus on the work, craft, and material obstacles between me and the result.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I move toward greater command: clarify authority, consolidate resources, calculate the consequences, and take responsibility for the larger structure.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "It depends too much on the objective.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Aquarius",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Venus",
          "alternativeRuler": "Saturn/Uranus",
          "keywords": [
            "dissent",
            "alliance",
            "social cost",
            "estrangement",
            "reform",
            "unconventional values"
          ],
          "kernel": "Relates to groups through dissent, unconventional alliances, reform, social cost, estrangement, and values that resist conformity."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Mercury",
          "alternativeRuler": "Mercury",
          "keywords": [
            "systems thinking",
            "strategy",
            "analysis",
            "earned progress",
            "networks",
            "technical skill"
          ],
          "kernel": "Relates to groups through systems thinking, strategy, networks, technical skill, analysis, and earned progress."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Moon",
          "alternativeRuler": "Venus",
          "keywords": [
            "adaptation",
            "unstable effort",
            "group emotion",
            "improvisation",
            "detachment",
            "shifting loyalties"
          ],
          "kernel": "Relates to groups through adaptation, improvisation, collective feeling, detachment, and changing allegiance as conditions shift."
        }
      ],
      "questions": [
        {
          "id": "decan_aquarius_q1",
          "prompt": "When you are part of a group or system, what role do you most naturally fall into?",
          "options": [
            {
              "text": "I notice where the shared values no longer make sense and tend to question the norm, form unusual alliances, or accept some social distance in order to reform it.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I map how the system works. I want to understand the network, improve the strategy, connect the right information, and make progress through technical or structural intelligence.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I read the changing atmosphere and adapt. I may move between engagement and detachment, improvising according to the group's needs without wanting to be emotionally captured by it.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these consistently describes my role.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_aquarius_q2",
          "prompt": "When a community or institution stops working well, what is your first instinct?",
          "options": [
            {
              "text": "Challenge the assumptions and values underneath it, even if that creates disagreement or distance from the group.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "Diagnose the system: trace the information, incentives, network, or process and design a smarter way for it to function.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "Adjust to the changing field, improvise with whoever is still participating, and stay flexible about where my allegiance or involvement belongs.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "I do not have a clear default response.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    },
    {
      "sign": "Pisces",
      "decans": [
        {
          "decan": 1,
          "range": "0°00′–9°59′59″",
          "classicalRuler": "Saturn",
          "alternativeRuler": "Jupiter/Neptune",
          "keywords": [
            "relinquishment",
            "exile",
            "boundary",
            "depletion",
            "contemplation",
            "spiritual severity"
          ],
          "kernel": "Meets dissolution through relinquishment, boundary, contemplation, conservation, exile, and learning what cannot be carried."
        },
        {
          "decan": 2,
          "range": "10°00′–19°59′59″",
          "classicalRuler": "Jupiter",
          "alternativeRuler": "Moon",
          "keywords": [
            "fulfillment",
            "generosity",
            "imagination",
            "receptivity",
            "pleasure",
            "emotional abundance"
          ],
          "kernel": "Meets dissolution through receptivity, imagination, generosity, emotional abundance, fulfillment, and allowing experience to expand."
        },
        {
          "decan": 3,
          "range": "20°00′–29°59′59″",
          "classicalRuler": "Mars",
          "alternativeRuler": "Mars/Pluto",
          "keywords": [
            "completion",
            "release",
            "crisis",
            "sacrifice",
            "decisive ending",
            "renewal"
          ],
          "kernel": "Meets dissolution by decisively completing, releasing, sacrificing, severing, and carrying a cycle across its ending into renewal."
        }
      ],
      "questions": [
        {
          "id": "decan_pisces_q1",
          "prompt": "When something in your life is clearly dissolving or coming to an end, what is your most natural relationship to the transition?",
          "options": [
            {
              "text": "I withdraw, conserve energy, and accept that some things must be relinquished. Boundaries and contemplation help me understand what I can no longer carry.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "I open to what the transition makes possible. Imagination, generosity, receptivity, beauty, or emotional connection help me experience the ending as part of a larger flow.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "I need the ending to become real. I make the decisive release, sacrifice, confrontation, or final push that allows the old cycle to finish and something new to begin.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "None of these is clearly more natural.",
              "returns": {
                "decan": null
              }
            }
          ]
        },
        {
          "id": "decan_pisces_q2",
          "prompt": "When you are overwhelmed by circumstances larger than your immediate control, what restores your sense of agency?",
          "options": [
            {
              "text": "Reducing what I am carrying, stepping back, protecting my boundaries, and becoming quiet enough to know what must be surrendered.",
              "returns": {
                "decan": 1
              }
            },
            {
              "text": "Allowing more room for feeling, imagination, compassion, pleasure, or generosity until I can sense possibilities beyond the immediate pressure.",
              "returns": {
                "decan": 2
              }
            },
            {
              "text": "Making a concrete ending or release: deciding what is over, cutting the tie, finishing the task, or acting through the crisis so the energy can move again.",
              "returns": {
                "decan": 3
              }
            },
            {
              "text": "My response changes too much to choose.",
              "returns": {
                "decan": null
              }
            }
          ]
        }
      ]
    }
  ]
}
```
