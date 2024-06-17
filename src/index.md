---
toc: false
---

<style>

 #observablehq-center, .observablehq, #observablehq-main {
   margin: 0px !important;
 }

 p {
   max-width: 800px;
 }

 ul {
   padding-top: 0;
   margin-top: 0;
 }

 #observablehq-center {
   display:flex;
   flex-direction:column;
   align-items: center;
   justify-content: center;
 }

 #observablehq-main {
   display: flex;
   flex-direction: column;
   justify-content: center;
 }

 #observablehq-footer {
   margin: 1rem;
 }

</style>

```js
import maplibregl from "npm:maplibre-gl@4.0.2";
import { PMTiles, Protocol } from "npm:pmtiles@3.0.3";
```

```js
const laMap = FileAttachment('so_cal.pmtiles');
const mapStyle = FileAttachment("maptiler-3d-gl-style.json").json();
const mapFile = new PMTiles(laMap.href)
const permits = FileAttachment("la_permits_issued.parquet").parquet();
```

```js 
const formattedPermits = view(Inputs.table(permits, {
  format: {
    issue_date: (x) => new Date(x).toISOString().slice(0, 10),
    submitted_date: (x) => new Date(x).toISOString().slice(0, 10),
    status_date: (x) => new Date(x).toISOString().slice(0, 10),
    refresh_time: (x) => new Date(x).toISOString().slice(0, 10),
  }
}))
```

<link rel="stylesheet" type="text/css" href="npm:maplibre-gl@4.0.2/dist/maplibre-gl.css">

```js
const parseGeolocation = (pointString) => {
  const regex = /POINT\s*\(\s*([-\d.]+)\s+([-\d.]+)\s*\)/
  const match = pointString.match(regex)
  if (match && match.length === 3) {
    const longitude = match[1]
    const latitude = match[2]
    return [parseFloat(longitude), parseFloat(latitude)]
  }
  return null
}
```

```js
const protocol = new Protocol();
maplibregl.addProtocol("pmtiles", protocol.tile)
protocol.add(mapFile);

// process Permits for Geometry 
const geoBuildingData = {
  type: "FeatureCollection",
  name: "permittedBuildings",
  crs: { type: "name", properties: { name: "urn:ogc:def:crs:OGC:1.3:CRS84" } },
  features: [],
}

formattedPermits.map((permit) => {
  const {geolocation, ...rest} = permit;
  geoBuildingData.features.push({
    type: "Feature",
    properties: {...rest},
    geometry: { type: "Point", coordinates: parseGeolocation(geolocation) },
  })
})
```

<div id="mapContainer" style="position: relative; height: calc(100vh - 300px); width: 100%;">
  <div id="features" style="z-index: 100;"></div>
</div>

```js
const map = new maplibregl.Map({
  container: "mapContainer",
  zoom: 12,
  maxZoom: 16,
  minZoom: 10,
  center: [-118.243683, 34.052235],
  pitch: 20,
  zoom: 8.6,
  maxBounds: [
  [-120, 32],
  [-116, 36],
  ],
  maplibreLogo: true,
  logoPosition: "bottom-left",
  style: {
  version: 8,
    sources: {
      openmaptiles: {
        type: "vector",
        tiles: ["pmtiles://" + mapFile.source.getKey() + "/{z}/{x}/{y}"],
      },
    },
    layers: mapStyle.layers,
    glyphs: "https://m-clare.github.io/map-glyphs/fonts/{fontstack}/{range}.pbf",
  }
})

map.on("load", () => {
  map.addSource("bldg-data", {
    type: "geojson",
    data: geoBuildingData,
  })

map.addLayer({
  id: "bldg",
  source: "bldg-data",
  type: "circle",
  paint: {
    "circle-radius": 5,
    "circle-color": "#000000"
  }
  })
  
})

```

