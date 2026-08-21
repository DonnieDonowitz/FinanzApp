import { useCallback, useMemo, useState } from 'react';
import { useAppContext } from '../context/AppContext';
import { Transaction } from '../context/types';
import { getCurrentMonth, getCurrentDate } from '../utils/format';

export function useTransactions() {
  const { state, dispatch, db } = useAppContext();
  const transactions = state.transactions;

  const [filterType, setFilterType] = useState<'all' | 'income' | 'expense'>('all');
  const [filterMonth, setFilterMonth] = useState<string>(getCurrentMonth());
  const [filterCategoryId, setFilterCategoryId] = useState<number | null>(null);

  const filteredTransactions = useMemo(() => {
    return transactions.filter((t) => {
      if (filterType !== 'all' && t.type !== filterType) return false;
      if (!t.date.startsWith(filterMonth)) return false;
      if (filterCategoryId !== null && t.category_id !== filterCategoryId) return false;
      return true;
    });
  }, [transactions, filterType, filterMonth, filterCategoryId]);

  const allFilteredTransactions = useMemo(() => {
    return transactions.filter((t) => {
      if (filterType !== 'all' && t.type !== filterType) return false;
      if (filterCategoryId !== null && t.category_id !== filterCategoryId) return false;
      return true;
    });
  }, [transactions, filterType, filterCategoryId]);

  const recentTransactions = useMemo(() => transactions.slice(0, 5), [transactions]);

  const balance = useMemo(() => {
    return transactions.reduce((acc, t) => {
      return t.type === 'income' ? acc + t.amount : acc - t.amount;
    }, 0);
  }, [transactions]);

  const totalIncome = useMemo(() => {
    return transactions
      .filter((t) => t.type === 'income')
      .reduce((acc, t) => acc + t.amount, 0);
  }, [transactions]);

  const totalExpense = useMemo(() => {
    return transactions
      .filter((t) => t.type === 'expense')
      .reduce((acc, t) => acc + t.amount, 0);
  }, [transactions]);

  const monthlyIncome = useMemo(() => {
    return transactions
      .filter((t) => t.type === 'income' && t.date.startsWith(filterMonth))
      .reduce((acc, t) => acc + t.amount, 0);
  }, [transactions, filterMonth]);

  const monthlyExpense = useMemo(() => {
    return transactions
      .filter((t) => t.type === 'expense' && t.date.startsWith(filterMonth))
      .reduce((acc, t) => acc + t.amount, 0);
  }, [transactions, filterMonth]);

  const addTransaction = useCallback(
    async (tx: Omit<Transaction, 'id' | 'recurring_id'> & { recurring_id?: number | null }) => {
      if (!db) return;
      const txDate = tx.date || getCurrentDate();
      const result = await db.runAsync(
        'INSERT INTO transactions (amount, description, category_id, date, type, recurring_id) VALUES (?, ?, ?, ?, ?, ?)',
        [tx.amount, tx.description, tx.category_id, txDate, tx.type, tx.recurring_id ?? null]
      );
      const newTx: Transaction = { ...tx, id: result.lastInsertRowId, date: txDate, recurring_id: tx.recurring_id ?? null };
      dispatch({ type: 'ADD_TRANSACTION', payload: newTx });
      return newTx;
    },
    [db, dispatch]
  );

  const updateTransaction = useCallback(
    async (tx: Transaction) => {
      if (!db) return;
      await db.runAsync(
        'UPDATE transactions SET amount = ?, description = ?, category_id = ?, date = ?, type = ?, recurring_id = ? WHERE id = ?',
        [tx.amount, tx.description, tx.category_id, tx.date, tx.type, tx.recurring_id ?? null, tx.id]
      );
      dispatch({ type: 'UPDATE_TRANSACTION', payload: tx });
    },
    [db, dispatch]
  );

  const deleteTransaction = useCallback(
    async (id: number) => {
      if (!db) return;
      await db.runAsync('DELETE FROM transactions WHERE id = ?', [id]);
      dispatch({ type: 'DELETE_TRANSACTION', payload: id });
    },
    [db, dispatch]
  );

  const getCategorySpent = useCallback(
    (categoryId: number, month: string) => {
      return transactions
        .filter(
          (t) =>
            t.type === 'expense' &&
            t.category_id === categoryId &&
            t.date.startsWith(month)
        )
        .reduce((acc, t) => acc + t.amount, 0);
    },
    [transactions]
  );

  return {
    transactions,
    filteredTransactions,
    allFilteredTransactions,
    recentTransactions,
    balance,
    totalIncome,
    totalExpense,
    monthlyIncome,
    monthlyExpense,
    filterType,
    setFilterType,
    filterMonth,
    setFilterMonth,
    filterCategoryId,
    setFilterCategoryId,
    addTransaction,
    updateTransaction,
    deleteTransaction,
    getCategorySpent,
  };
}
