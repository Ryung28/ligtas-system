export const TACTICAL_THEME = {
    borderRadius: {
        asymmetric: '16px 4px 16px 16px',
        standard: '12px',
        interactive: '8px'
    },
    shadows: {
        soft: '0 20px 40px -15px rgba(0,0,0,0.05)',
        tactical: '0 10px 15px -3px rgba(0,0,0,0.05)',
        commandCenter: '0 0 0 1px rgba(0,0,0,0.05), 0 20px 50px -12px rgba(0,0,0,0.15)',
        glow: '0 0 15px rgba(59, 130, 246, 0.1)'
    },
    glass: {
        background: 'rgba(255, 255, 255, 0.95)',
        blur: 'backdrop-blur-xl',
        border: 'border-slate-200/60'
    }
} as const;

export type TacticalTheme = typeof TACTICAL_THEME;
