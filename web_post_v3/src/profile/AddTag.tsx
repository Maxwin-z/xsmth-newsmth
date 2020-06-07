import React, { useEffect } from "react";
// import "@simonwep/pickr/dist/themes/classic.min.css"; // 'classic' theme
import "@simonwep/pickr/dist/themes/monolith.min.css"; // 'monolith' theme
import Pickr from "@simonwep/pickr";
export default function AddTag() {
  const show = () => {
    const picker = Pickr.create({
      el: ".color-picker",
      theme: "monolith", // or 'monolith', or 'nano'
      //   position: "bottom-middle",
      //   container: ".picker-container",
      swatches: [
        "rgba(244, 67, 54, 1)",
        "rgba(233, 30, 99, 0.95)",
        "rgba(156, 39, 176, 0.9)",
        "rgba(103, 58, 183, 0.85)",
        "rgba(63, 81, 181, 0.8)",
        "rgba(33, 150, 243, 0.75)",
        "rgba(3, 169, 244, 0.7)",
        "rgba(0, 188, 212, 0.7)",
        "rgba(0, 150, 136, 0.75)",
        "rgba(76, 175, 80, 0.8)",
        "rgba(139, 195, 74, 0.85)",
        "rgba(205, 220, 57, 0.9)",
        "rgba(255, 235, 59, 0.95)",
        "rgba(255, 193, 7, 1)"
      ],

      components: {
        // Main components
        preview: true,
        opacity: true,
        hue: true,

        // Input / output Options
        interaction: {
          hex: true,
          rgba: true,
          hsla: true,
          hsva: true,
          cmyk: true,
          input: true,
          clear: true,
          save: true
        }
      }
    });
  };
  return (
    <div
      className="main"
      style={{
        display: "flex",
        flexDirection: "column",
        justifyItems: "center",
        alignItems: "center",
        fontSize: "12px"
      }}
    >
      <h1>AddTag</h1>
      <button onClick={show}>Show</button>
      <div
        className="color-picker"
        style={{
          display: "flex"
        }}
      ></div>
    </div>
  );
}
