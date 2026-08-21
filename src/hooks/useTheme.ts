import { useCallback } from 'react';
import { useAppContext } from '../context/AppContext';
import { getColors, ThemeColors } from '../utils/colors';

export function useTheme() {
  const { state, dispatch, db } = useAppContext();
  const theme = state.settings.theme;
  const colors: ThemeColors = getColors(theme);

  const toggleTheme = useCallback(async () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    dispatch({ type: 'SET_SETTINGS', payload: { theme: newTheme } });
    if (db) {
      try {
        await db.runAsync('UPDATE app_settings SET value = ? WHERE key = ?', [newTheme, 'theme']);
      } catch {
        // Ignore DB write errors – UI already updated
      }
    }
  }, [db, dispatch, theme]);

  return { theme, colors, toggleTheme };
}
