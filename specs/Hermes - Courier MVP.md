# Hermes - Courier MVP

## Purpose

Prove one thing:

> Hermes can carry a ticketed parcel from an origin to a service, leave the ticket unresolved while the service holds it, resume the ticket when called back, and deliver the returned parcel to the original final addressee.

The first real route will be the founding delivery of Orbo:

```text
This is Ean.
For delivery to Hestia.
Via the Moirai.
```

Hermes is a courier. He does not calculate, interpret, supervise, poll, repair, or decide what a parcel means.

## MVP laws

1. The final addressee is fixed on the original ticket.
2. Service destination and final addressee are distinct.
3. Hermes checks routing, identity, custody, parcel kind, and delivery expectation only.
4. Tickets are immutable.
5. The Hermes Manifest is durable and append-only.
6. A ticket remains unresolved while a service holds the parcel.
7. Hermes resumes only when called back.
8. A completed ticket is never reopened; new work gets a new linked ticket.
9. Duplicate callbacks must not create duplicate delivery.

## Canonical objects

Only five objects are required for v1:

- `HermesTicket`
- `HermesParcel`
- `HermesExpectation`
- `HermesReceipt`
- `HermesManifestEvent`

A ticket needs only enough information to describe the obligation:

```text
ticketID
subjectID
serviceDestination
finalAddressee
expectedReturnKind
```

For the founding delivery:

```text
subject: Ean
serviceDestination: Moirai
finalAddressee: Hestia
expectedReturn: AtroposPackage
```

## Hermes Manifest

The manifest belongs to Hermes and lives in the engraved Orbo's durable persistent data.

It is append-only. Current state is reconstructed from its events rather than replacing history.

Minimum event vocabulary:

```text
ticketOpened
deliveredToService
serviceReturnAccepted
deliveredToAddressee
receiptRecorded
resolved
```

While the Moirai hold the parcel, the ticket remains unresolved.

The manifest records journeys. It does not store another copy of the finished Connectome resident.

## Hermes Route Registry

Hermes also owns a small compiled route registry in OrboCore.

The registry says what delivery contracts are valid. The manifest says what actually happened.

Initial contract:

```text
Moirai
accepts: NatalCommission
returns: AtroposPackage

Hestia
accepts: AtroposPackage
```

The registry contains no astrological rules.

## Courier behavior

Hermes needs four operations for v1:

```text
accept(ticket, parcel)
deliverToService()
acceptReturn()
deliverToFinalAddressee()
```

When a service calls Hermes back, Hermes verifies only the envelope:

```text
same ticket
same subject
expected sender
expected parcel kind
same final addressee
```

Hermes does not inspect the tapestry inside the parcel.

A receipt from the final addressee resolves the ticket. Receipt means custody was accepted, not that the addressee has approved the contents after opening them.

If Hestia later rejects a tapestry made by the Moirai, Hestia calls Hermes and a new linked ticket is opened back to the Moirai. The original delivery history remains unchanged.

## Build order

1. Create the five Hermes domain objects.
2. Build the append-only durable manifest and state reconstruction.
3. Build the minimal route registry.
4. Build the four courier operations.
5. Prove Hermes with dummy tickets and dummy destinations.
6. Freeze Hermes MVP.
7. Separately finish Clotho's canonical natal-address/Timespine entrance.
8. Then connect the real route: `Hermes -> Moirai -> Hermes -> Hestia`.

## Dummy proving suite

The MVP should prove:

```text
valid parcel reaches dummy service
ticket remains unresolved after service handoff
correct callback resumes the ticket
wrong ticket is rejected
wrong parcel kind is rejected
changed final addressee is rejected
receipt resolves the ticket
duplicate callback does not duplicate delivery
manifest reconstructs current state
```

## Explicit non-goals

No polling.
No queues.
No retries.
No workflow engine.
No multi-step route system.
No full Hestia implementation.
No astrology knowledge inside Hermes.
No redesign of Clotho, Lachesis, or Atropos for Hermes.

## MVP acceptance criterion

Hermes v1 is complete when a dummy ticket can truthfully record:

```text
I delivered this parcel to the service.
I remained responsible for the unresolved ticket.
The service called me back.
I verified the returned envelope.
I delivered it to the original addressee.
I recorded the receipt.
The append-only manifest now shows the completed journey.
```
