const defaultTheme = require('tailwindcss/defaultTheme')
let colors = require("tailwindcss/colors");

function withOpacity(variableName) {
  return ({ opacityValue }) => {
    if (opacityValue !== undefined) {
      return `rgba(var(${variableName}), ${opacityValue})`;
    }
    return `rgb(var(${variableName}))`;
  };
}

module.exports = {
  content: [
    "./app/views/**/*.{rb,erb}",
    "./app/models/**/*.rb",
    // "./app/views/components/**/*rb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
    "./public/*.html",
    "./config/locales/**/*.yml",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        mortimer: '#1f9cd8',
        neutral: colors.slate,
        positive: colors.green,
        urge: colors.violet,
        warning: colors.yellow,
        info: colors.blue,
        critical: colors.red,
      },
      textColor: {
        skin: {
          primary: withOpacity("--color-primary"),
          a11y: withOpacity("--color-a11y"),
        },
      },
      backgroundColor: {
        skin: {
          primary: withOpacity("--color-primary"),
          a11y: withOpacity("--color-a11y"),
        },
      },
      ringColor: {
        skin: {
          primary: withOpacity("--color-primary"),
        },
      },
      borderColor: {
        skin: {
          primary: withOpacity("--color-primary"),
          a11y: withOpacity("--color-a11y"),
        },
      },
      // backgroundImage: {
      //   "edit-dots": "url('/images/bg-dots.svg')",
      // },

      keyframes: {
        swing: {
          "0%,100%": { transform: "rotate(15deg)" },
          "50%": { transform: "rotate(-15deg)" },
        },
        wiggle: {
          "0%, 100%": { transform: "rotate(-3deg)" },
          "50%": { transform: "rotate(3deg)" },
        },
        pulse: {
          "0%, 100%": { opacity: 1 },
          "50%": { opacity: 0 },
        },
        grow: {
          "0%": { transform: "scale(0.8)" },
          "50%": { transform: "scale(1.2)" },
          "100%": { transform: "scale(1)" },
        },
      },
      animation: {
        grow: "grow 1s infinite",
        pulse: "pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite",
        swing: "swing 1s infinite ease-in-out",
        wiggle: "wiggle 500ms ease-in-out",
      },
    },
  },
  plugins: [
    // require("a17t"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
