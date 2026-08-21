import * as SQLite from 'expo-sqlite';

const DEFAULT_EXPENSE_CATEGORIES = [
  { name: 'Alimentari', color: '#E53935', type: 'expense' as const },
  { name: 'Trasporti', color: '#1E88E5', type: 'expense' as const },
  { name: 'Abitazione', color: '#8E24AA', type: 'expense' as const },
  { name: 'Salute', color: '#D81B60', type: 'expense' as const },
  { name: 'Intrattenimento', color: '#FB8C00', type: 'expense' as const },
  { name: 'Abbigliamento', color: '#00ACC1', type: 'expense' as const },
  { name: 'Educazione', color: '#43A047', type: 'expense' as const },
  { name: 'Ristoranti', color: '#F4511E', type: 'expense' as const },
  { name: 'Bollette', color: '#5E35B1', type: 'expense' as const },
  { name: 'Altro', color: '#757575', type: 'expense' as const },
];

const DEFAULT_INCOME_CATEGORIES = [
  { name: 'Stipendio', color: '#2E7D32', type: 'income' as const },
  { name: 'Freelance', color: '#00838F', type: 'income' as const },
  { name: 'Investimenti', color: '#1565C0', type: 'income' as const },
  { name: 'Altro', color: '#6A1B9A', type: 'income' as const },
];

export async function seedCategories(db: SQLite.SQLiteDatabase): Promise<void> {
  const result = await db.getFirstAsync<{ count: number }>('SELECT COUNT(*) as count FROM categories');
  if (result && result.count > 0) return;

  const allCategories = [...DEFAULT_EXPENSE_CATEGORIES, ...DEFAULT_INCOME_CATEGORIES];
  for (const cat of allCategories) {
    await db.runAsync(
      'INSERT INTO categories (name, icon, color, type, is_default) VALUES (?, ?, ?, ?, 1)',
      [cat.name, 'tag', cat.color, cat.type]
    );
  }
}

export async function seedSettings(db: SQLite.SQLiteDatabase): Promise<void> {
  const result = await db.getFirstAsync<{ count: number }>('SELECT COUNT(*) as count FROM app_settings');
  if (result && result.count > 0) return;

  await db.runAsync('INSERT INTO app_settings (key, value) VALUES (?, ?)', ['theme', 'light']);
}
