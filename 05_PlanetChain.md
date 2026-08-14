# PlanetChain

```ts
interface PlanetChain {
  startPlanet: string;
  path: string[];
  terminalType: "fixed-point" | "mutual-reception" | "cycle";
  terminalCycleId: string;
  distanceToCycle: number;
}
```
