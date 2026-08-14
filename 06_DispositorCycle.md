# DispositorCycle

```ts
interface DispositorCycle {
  id: string;
  type: "fixed-point" | "mutual-reception" | "cycle";
  members: string[];
  length: number;
  incomingPlanets: string[];
}
```
