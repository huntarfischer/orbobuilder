# RegulatorySnapshot

```ts
interface RegulatorySnapshot {
  metadata;
  planetTable;
  houseTable;
  planetGraph;
  houseGraph;
  chains;
  cycles;
  indexes;
  metrics;
}
```

## Metadata

- astroStateId
- source
- timestamp
- stateKey
- topologyKey

## Indexes

- planetByName
- houseByNumber
- chainByPlanet
- cycleByPlanet
- planetsDisposedByPlanet
- housesRuledByPlanet
- housesRoutingToHouse
