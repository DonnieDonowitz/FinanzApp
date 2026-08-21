import { useCallback } from 'react';
import { useAppContext } from '../context/AppContext';
import { Category } from '../context/types';

export function useCategories() {
  const { state, dispatch, db, refreshData } = useAppContext();

  const categories = state.categories;
  const expenseCategories = categories.filter((c) => c.type === 'expense');
  const incomeCategories = categories.filter((c) => c.type === 'income');

  const addCategory = useCallback(
    async (category: Omit<Category, 'id'>) => {
      if (!db) return;
      const result = await db.runAsync(
        'INSERT INTO categories (name, icon, color, type, is_default) VALUES (?, ?, ?, ?, 0)',
        [category.name, category.icon, category.color, category.type]
      );
      const newCategory: Category = { ...category, id: result.lastInsertRowId, is_default: 0 };
      dispatch({ type: 'ADD_CATEGORY', payload: newCategory });
      return newCategory;
    },
    [db, dispatch]
  );

  const updateCategory = useCallback(
    async (category: Category) => {
      if (!db) return;
      await db.runAsync(
        'UPDATE categories SET name = ?, icon = ?, color = ?, type = ? WHERE id = ?',
        [category.name, category.icon, category.color, category.type, category.id]
      );
      dispatch({ type: 'UPDATE_CATEGORY', payload: category });
    },
    [db, dispatch]
  );

  const deleteCategory = useCallback(
    async (id: number) => {
      if (!db) return;
      await db.runAsync('DELETE FROM categories WHERE id = ?', [id]);
      dispatch({ type: 'DELETE_CATEGORY', payload: id });
    },
    [db, dispatch]
  );

  const getCategoryById = useCallback(
    (id: number | null): Category | undefined => {
      if (id === null) return undefined;
      return categories.find((c) => c.id === id);
    },
    [categories]
  );

  return {
    categories,
    expenseCategories,
    incomeCategories,
    addCategory,
    updateCategory,
    deleteCategory,
    getCategoryById,
  };
}
