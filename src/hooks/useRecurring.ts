import { useCallback } from 'react';
import { useAppContext } from '../context/AppContext';
import { RecurringTransaction, Transaction } from '../context/types';
import { getNextDueDate, isDue } from '../utils/scheduling';
import { getCurrentDate } from '../utils/format';

export function useRecurring() {
  const { state, dispatch, db } = useAppContext();
  const recurring = state.recurring;

  const dueTransactions = recurring.filter((r) => r.active === 1 && isDue(r.next_due_date));

  const processDueRecurring = useCallback(async (): Promise<Transaction[]> => {
    if (!db) return [];
    const processed: Transaction[] = [];
    const today = getCurrentDate();

    for (const r of state.recurring) {
      if (r.active !== 1 || !isDue(r.next_due_date)) continue;

      // Create a transaction from the recurring
      const txResult = await db.runAsync(
        'INSERT INTO transactions (amount, description, category_id, date, type, recurring_id) VALUES (?, ?, ?, ?, ?, ?)',
        [r.amount, r.description, r.category_id, today, r.type, r.id]
      );

      const newTx: Transaction = {
        id: txResult.lastInsertRowId,
        amount: r.amount,
        description: r.description,
        category_id: r.category_id,
        date: today,
        type: r.type,
        recurring_id: r.id,
      };
      processed.push(newTx);

      // Update next_due_date
      const nextDue = getNextDueDate(r.next_due_date, r.frequency);
      const isActive = !r.end_date || nextDue <= r.end_date;

      await db.runAsync(
        'UPDATE recurring_transactions SET next_due_date = ?, active = ? WHERE id = ?',
        [nextDue, isActive ? 1 : 0, r.id]
      );

      dispatch({ type: 'ADD_TRANSACTION', payload: newTx });
      dispatch({
        type: 'UPDATE_RECURRING',
        payload: { ...r, next_due_date: nextDue, active: isActive ? 1 : 0 },
      });
    }

    return processed;
  }, [db, state.recurring, dispatch]);

  const addRecurring = useCallback(
    async (rec: Omit<RecurringTransaction, 'id'>) => {
      if (!db) return;
      const result = await db.runAsync(
        'INSERT INTO recurring_transactions (amount, description, category_id, type, frequency, start_date, end_date, next_due_date, active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [rec.amount, rec.description, rec.category_id, rec.type, rec.frequency, rec.start_date, rec.end_date ?? null, rec.next_due_date, rec.active]
      );
      const newRec: RecurringTransaction = { ...rec, id: result.lastInsertRowId };
      dispatch({ type: 'ADD_RECURRING', payload: newRec });
      return newRec;
    },
    [db, dispatch]
  );

  const updateRecurring = useCallback(
    async (rec: RecurringTransaction) => {
      if (!db) return;
      await db.runAsync(
        'UPDATE recurring_transactions SET amount = ?, description = ?, category_id = ?, type = ?, frequency = ?, start_date = ?, end_date = ?, next_due_date = ?, active = ? WHERE id = ?',
        [rec.amount, rec.description, rec.category_id, rec.type, rec.frequency, rec.start_date, rec.end_date ?? null, rec.next_due_date, rec.active, rec.id]
      );
      dispatch({ type: 'UPDATE_RECURRING', payload: rec });
    },
    [db, dispatch]
  );

  const deleteRecurring = useCallback(
    async (id: number) => {
      if (!db) return;
      await db.runAsync('DELETE FROM recurring_transactions WHERE id = ?', [id]);
      dispatch({ type: 'DELETE_RECURRING', payload: id });
    },
    [db, dispatch]
  );

  return {
    recurring,
    dueTransactions,
    processDueRecurring,
    addRecurring,
    updateRecurring,
    deleteRecurring,
  };
}
