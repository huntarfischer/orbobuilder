# AstroState

```ts
interface AstroState {
  id: string;
  source:
    | "natal"
    | "synchronic"
    | "transit"
    | "solar_return"
    | "composite"
    | "mundane"
    | string;

  timestamp?: number;

  astroDNA: {
    Sun:number;
    Moon:number;
    Mercury:number;
    Venus:number;
    Mars:number;
    Jupiter:number;
    Saturn:number;
    Ascendant:number;
  };
}
```
