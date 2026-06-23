/** @type {import('tailwindcss').Config} */
export default {
  content: [
  './index.html',
  './src/**/*.{js,ts,jsx,tsx}'
],
  theme: {
    extend: {
      colors: {
        app: {
          bg: '#14121A',
          card: '#1E1B27',
          accent: '#9B7EF0',
          accentDark: '#7C5CFA',
          text: '#F3F4F6',
          muted: '#9CA3AF',
          border: 'rgba(155, 126, 240, 0.15)',
        }
      },
      fontFamily: {
        sans: ['"Plus Jakarta Sans"', 'sans-serif'],
      },
      backgroundImage: {
        'accent-gradient': 'linear-gradient(135deg, #9B7EF0 0%, #7C5CFA 100%)',
      }
    },
  },
  plugins: [],
}