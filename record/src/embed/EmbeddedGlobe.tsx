import Globe from "react-globe.gl";
import {useEffect, useMemo, useRef, useState} from "react";

import darkGlobeTexture from "../../../apps/mobile_app/assets/globe/earth_storybook_dark.png";
import lightGlobeTexture from "../../../apps/mobile_app/assets/globe/earth_storybook_light.png";
import bumpTexture from "../../../apps/mobile_app/assets/globe/earth-topology.png";
import countryShapes from "../../../apps/mobile_app/assets/globe/record_country_shapes.json";

type GlobeTheme = "dark" | "light";

type GlobeAnchor = {
  countryCode: string;
  countryName: string;
  latitude: number;
  longitude: number;
  markerCount: number;
  color: string;
};

type GlobeBootstrap = {
  theme?: GlobeTheme;
  initialCountryCode?: string | null;
  selectedCountryCode?: string | null;
  anchors?: GlobeAnchor[];
  selectableCountryCodes?: string[];
};

type CountryShape = {
  code: string;
  name: string;
  centroidLat: number;
  centroidLng: number;
  polygons: number[][][];
};

type CountryFeature = {
  type: "Feature";
  properties: {
    ISO_A2: string;
    ADMIN: string;
    visitCount: number;
    baseColor: string;
    centroidLat: number;
    centroidLng: number;
  };
  geometry:
    | {
        type: "Polygon";
        coordinates: number[][][];
      }
    | {
        type: "MultiPolygon";
        coordinates: number[][][][];
      };
};

declare global {
  interface Window {
    RecordBridge?: { postMessage: (message: string) => void };
    __RECORD_GLOBE_BOOTSTRAP__?: GlobeBootstrap;
    recordBootstrap?: (data: GlobeBootstrap) => void;
    recordSetSelectedCountry?: (countryCode: string | null) => void;
  }
}

const shapes = (countryShapes as {countries: CountryShape[]}).countries;
const shapeByCode = new Map(shapes.map((shape) => [shape.code, shape]));

function buildFeatures(anchors: GlobeAnchor[]) {
  const anchorByCode = new Map(anchors.map((anchor) => [anchor.countryCode, anchor]));
  const maxVisits = anchors.reduce(
    (max, anchor) => Math.max(max, anchor.markerCount),
    1,
  );

  return shapes.map<CountryFeature>((shape) => {
    const anchor = anchorByCode.get(shape.code);
    const visitCount = anchor?.markerCount ?? 0;
    const baseColor = anchor?.color ?? "#5b6b8d";
    const coordinates = shape.polygons.map((polygon) =>
      closeLinearRing(polygon.map(([lat, lng]) => [lng, lat])),
    );

    return {
      type: "Feature",
      properties: {
        ISO_A2: shape.code,
        ADMIN: shape.name,
        visitCount,
        baseColor: mixColor(
          baseColor,
          visitCount > 0 ? "#dbeafe" : "#1e293b",
          visitCount > 0 ? 0.18 + (visitCount / maxVisits) * 0.32 : 0,
        ),
        centroidLat: shape.centroidLat,
        centroidLng: shape.centroidLng,
      },
      geometry:
        coordinates.length === 1
          ? {
              type: "Polygon",
              coordinates: [coordinates[0]],
            }
          : {
              type: "MultiPolygon",
              coordinates: coordinates.map((polygon) => [polygon]),
            },
    };
  });
}

function closeLinearRing(points: number[][]) {
  if (points.length < 3) {
    return points;
  }
  const [firstLng, firstLat] = points[0];
  const [lastLng, lastLat] = points[points.length - 1];
  if (firstLng === lastLng && firstLat === lastLat) {
    return points;
  }
  return [...points, [firstLng, firstLat]];
}

function toRgb(hex: string) {
  const normalized = hex.replace("#", "");
  const value =
    normalized.length === 3
      ? normalized
          .split("")
          .map((item) => item + item)
          .join("")
      : normalized.padStart(6, "0").slice(0, 6);
  return {
    r: parseInt(value.slice(0, 2), 16),
    g: parseInt(value.slice(2, 4), 16),
    b: parseInt(value.slice(4, 6), 16),
  };
}

function mixColor(from: string, to: string, ratio: number) {
  const a = toRgb(from);
  const b = toRgb(to);
  const t = Math.max(0, Math.min(1, ratio));
  const r = Math.round(a.r + (b.r - a.r) * t);
  const g = Math.round(a.g + (b.g - a.g) * t);
  const bValue = Math.round(a.b + (b.b - a.b) * t);
  return `rgb(${r}, ${g}, ${bValue})`;
}

function rgba(hex: string, alpha: number) {
  const {r, g, b} = toRgb(hex);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

function postBridgeMessage(payload: object) {
  if (!window.RecordBridge?.postMessage) {
    return;
  }
  window.RecordBridge.postMessage(JSON.stringify(payload));
}

export default function EmbeddedGlobe() {
  const globeEl = useRef<any>(null);
  const containerRef = useRef<HTMLDivElement | null>(null);
  const [dimensions, setDimensions] = useState({width: 360, height: 360});
  const [bootstrap, setBootstrap] = useState<GlobeBootstrap>({
    theme: "dark",
    anchors: [],
    selectableCountryCodes: [],
    selectedCountryCode: null,
  });
  const [selectedCountryCode, setSelectedCountryCode] = useState<string | null>(
    null,
  );

  useEffect(() => {
    const reportError = (message: string) => {
      postBridgeMessage({type: "runtime_error", message});
    };
    const applyBootstrap = (data: GlobeBootstrap) => {
      setBootstrap((current) => ({
        ...current,
        ...data,
        anchors: data.anchors ?? current.anchors ?? [],
        selectableCountryCodes:
          data.selectableCountryCodes ?? current.selectableCountryCodes ?? [],
      }));
      setSelectedCountryCode(data.selectedCountryCode ?? data.initialCountryCode ?? null);
    };

    window.recordBootstrap = (data) => {
      applyBootstrap(data);
    };
    window.recordSetSelectedCountry = (countryCode) => {
      setSelectedCountryCode(countryCode);
    };

    if (window.__RECORD_GLOBE_BOOTSTRAP__) {
      applyBootstrap(window.__RECORD_GLOBE_BOOTSTRAP__);
    }

    const handleWindowError = (event: ErrorEvent) => {
      reportError(event.message || "Unknown embed error");
    };
    const handleUnhandledRejection = (event: PromiseRejectionEvent) => {
      reportError(
        event.reason instanceof Error
          ? event.reason.message
          : String(event.reason),
      );
    };
    window.addEventListener("error", handleWindowError);
    window.addEventListener("unhandledrejection", handleUnhandledRejection);
    postBridgeMessage({type: "ready"});

    return () => {
      window.removeEventListener("error", handleWindowError);
      window.removeEventListener("unhandledrejection", handleUnhandledRejection);
    };
  }, []);

  useEffect(() => {
    const updateDimensions = () => {
      const container = containerRef.current;
      const bounds = container?.getBoundingClientRect();
      const width = bounds?.width ?? window.innerWidth;
      const height = bounds?.height ?? window.innerHeight;
      setDimensions({
        width: Math.max(320, Math.round(width || 0)),
        height: Math.max(320, Math.round(height || 0)),
      });
    };
    updateDimensions();
    const observer =
      typeof ResizeObserver === "undefined"
        ? null
        : new ResizeObserver(() => updateDimensions());
    if (containerRef.current && observer) {
      observer.observe(containerRef.current);
    }
    window.addEventListener("resize", updateDimensions);
    return () => {
      observer?.disconnect();
      window.removeEventListener("resize", updateDimensions);
    };
  }, []);

  useEffect(() => {
    const controls = globeEl.current?.controls?.();
    if (!controls) {
      return;
    }
    controls.autoRotate = true;
    controls.autoRotateSpeed = 0.45;
    controls.enableZoom = false;
    controls.enablePan = false;
    controls.minDistance = 280;
    controls.maxDistance = 280;

    if (globeEl.current) {
      window.requestAnimationFrame(() => {
        globeEl.current?.pointOfView({altitude: 2.32}, 0);
      });
    }
  }, []);

  useEffect(() => {
    if (!selectedCountryCode || !globeEl.current) {
      return;
    }
    const shape = shapeByCode.get(selectedCountryCode);
    if (!shape) {
      return;
    }
    globeEl.current.pointOfView(
      {
        lat: shape.centroidLat,
        lng: shape.centroidLng,
        altitude: 1.82,
      },
      900,
    );
  }, [selectedCountryCode]);

  const theme = bootstrap.theme === "light" ? "light" : "dark";
  const features = useMemo(
    () => buildFeatures(bootstrap.anchors ?? []),
    [bootstrap.anchors],
  );
  const labelsData = useMemo(() => {
    if (!selectedCountryCode) {
      return [];
    }
    const shape = shapeByCode.get(selectedCountryCode);
    if (!shape) {
      return [];
    }
    return [
      {
        code: shape.code,
        text: shape.name,
        lat: shape.centroidLat,
        lng: shape.centroidLng,
      },
    ];
  }, [selectedCountryCode]);

  const polygonCapColor = (feature: CountryFeature) => {
    const visited = feature.properties.visitCount > 0;
    const selected = feature.properties.ISO_A2 === selectedCountryCode;
    if (selected) {
      return theme === "dark"
        ? rgba("#93c5fd", 0.92)
        : rgba("#2563eb", 0.78);
    }
    if (visited) {
      return theme === "dark"
        ? rgba(feature.properties.baseColor, 0.82)
        : rgba(feature.properties.baseColor, 0.72);
    }
    return theme === "dark"
      ? "rgba(255,255,255,0.04)"
      : "rgba(15,23,42,0.02)";
  };

  const polygonSideColor = (feature: CountryFeature) =>
    feature.properties.ISO_A2 === selectedCountryCode
      ? polygonCapColor(feature)
      : theme === "dark"
      ? "rgba(255,255,255,0.03)"
      : "rgba(15,23,42,0.02)";

  const polygonStrokeColor = (feature: CountryFeature) =>
    feature.properties.ISO_A2 === selectedCountryCode
      ? theme === "dark"
        ? "rgba(191,219,254,0.60)"
        : "rgba(37,99,235,0.32)"
      : "rgba(255,255,255,0.04)";

  const polygonAltitude = (feature: CountryFeature) => {
    const selected = feature.properties.ISO_A2 === selectedCountryCode;
    if (selected) {
      return 0.028;
    }
    return feature.properties.visitCount > 0 ? 0.014 : 0.008;
  };

  const selectedTexture =
    theme === "light" ? lightGlobeTexture : darkGlobeTexture;

  return (
    <div
      ref={containerRef}
      style={{
        width: "100%",
        height: "100%",
        position: "relative",
        overflow: "hidden",
        background: "transparent",
      }}
    >
      <Globe
        ref={globeEl}
        width={dimensions.width}
        height={Math.max(320, dimensions.height)}
        backgroundColor="rgba(0,0,0,0)"
        showGlobe
        showAtmosphere
        globeImageUrl={selectedTexture}
        bumpImageUrl={bumpTexture}
        atmosphereColor={theme === "dark" ? "#4fc3f7" : "#60a5fa"}
        atmosphereAltitude={theme === "dark" ? 0.14 : 0.08}
        polygonsData={features}
        polygonCapColor={polygonCapColor}
        polygonSideColor={polygonSideColor}
        polygonStrokeColor={polygonStrokeColor}
        polygonAltitude={polygonAltitude}
        polygonsTransitionDuration={220}
        labelsData={labelsData}
        labelLat={(item: any) => item.lat}
        labelLng={(item: any) => item.lng}
        labelText={(item: any) => item.text}
        labelSize={() => 1.16}
        labelDotRadius={() => 0.42}
        labelColor={() => "rgba(255,255,255,0.96)"}
        labelResolution={3}
        labelAltitude={() => 0.03}
        labelIncludeDot
        onLabelClick={(item: any) => {
          postBridgeMessage({
            type: "country_open",
            countryCode: item.code,
          });
        }}
        onPolygonClick={(feature: any) => {
          const countryCode = feature?.properties?.ISO_A2 as string | undefined;
          if (!countryCode) {
            return;
          }
          if (countryCode === selectedCountryCode) {
            postBridgeMessage({type: "country_open", countryCode});
            return;
          }
          setSelectedCountryCode(countryCode);
          postBridgeMessage({type: "country_selected", countryCode});
        }}
      />
    </div>
  );
}
