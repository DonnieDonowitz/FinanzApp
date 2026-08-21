import React, { createContext, useContext, useReducer, useEffect, useCallback, ReactNode } from 'react';
import { AppState, AppAction, Category, Transaction, RecurringTransaction } from './types';
import { appReducer, initialState } from './AppReducer';
import { initializeDatabase } from './../database/schema';
import { seedCategories, seedSettings } from './../database/seed';
import { queryAll } from './../database/helpers';
import { isDue, getNextDueDate } from './../utils/scheduling';
import { getCurrentDate } from './../utils/format';
import type { SQLiteDatabase } from 'expo-sqlite';

interface AppContextType {
  state: AppState;
  dispatch: React.Dispatch<AppAction>;
  db: SQLiteDatabase | null;
  refreshData: () => Promise<void>;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export function AppProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(appReducer, initialState);
  const [db, setDb] = React.useState<SQLiteDatabase | null>(null);

  const loadData = useCallback(async (database: SQLiteDatabase) => {
    const [categories, transactions, recurring, settingsRows] = await Promise.all([
      queryAll<Category>(database, 'SELECT * FROM categories ORDER BY type, name'),
      queryAll<Transaction>(database, 'SELECT * FROM transactions ORDER BY date DESC, id DESC'),
      queryAll<RecurringTransaction>(database, 'SELECT * FROM recurring_transactions ORDER BY next_due_date'),
      queryAll<{ key: string; value: string }>(database, 'SELECT * FROM app_settings'),
    ]);

    const themeSetting = settingsRows.find((s) => s.key === 'theme');
    const theme = themeSetting?.value === 'dark' ? 'dark' : 'light';

    dispatch({ type: 'SET_CATEGORIES', payload: categories });
    dispatch({ type: 'SET_TRANSACTIONS', payload: transactions });
    dispatch({ type: 'SET_RECURRING', payload: recurring });
    dispatch({ type: 'SET_SETTINGS', payload: { theme } });
    dispatch({ type: 'SET_LOADING', payload: false });
  }, []);

  const refreshData = useCallback(async () => {
    if (db) {
      await loadData(db);
    }
  }, [db, loadData]);

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        const database = await initializeDatabase();
        await seedCategories(database);
        await seedSettings(database);
        if (mounted) {
          setDb(database);
          await loadData(database);

          // Auto-process due recurring transactions on startup
          try {
            let processedCount = 0;
            const today = getCurrentDate();
            const activeRecurring = await queryAll<RecurringTransaction>(
              database,
              'SELECT * FROM recurring_transactions WHERE active = 1'
            );

            for (const r of activeRecurring) {
              if (!isDue(r.next_due_date)) continue;

              // Insert a new transaction from the recurring template
              await database.runAsync(
                'INSERT INTO transactions (amount, description, category_id, date, type, recurring_id) VALUES (?, ?, ?, ?, ?, ?)',
                [r.amount, r.description, r.category_id, today, r.type, r.id]
              );

              // Calculate the next due date and whether the recurring is still active
              const nextDue = getNextDueDate(r.next_due_date, r.frequency);
              const stillActive = !r.end_date || nextDue <= r.end_date;

              await database.runAsync(
                'UPDATE recurring_transactions SET next_due_date = ?, active = ? WHERE id = ?',
                [nextDue, stillActive ? 1 : 0, r.id]
              );

              processedCount++;
            }

            // Reload data if any recurring transactions were processed
            if (processedCount > 0) {
              await loadData(database);
            }
          } catch (err) {
            console.warn('Failed to process recurring transactions:', err);
          }
        }
      } catch (error) {
        console.error('Failed to initialize database:', error);
        if (mounted) {
          dispatch({ type: 'SET_LOADING', payload: false });
        }
      }
    })();
    return () => {
      mounted = false;
    };
  }, []);

  return (
    <AppContext.Provider value={{ state, dispatch, db, refreshData }}>
      {children}
    </AppContext.Provider>
  );
}

export function useAppContext(): AppContextType {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useAppContext must be used within an AppProvider');
  }
  return context;
}
