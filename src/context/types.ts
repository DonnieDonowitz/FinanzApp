export interface Category {
  id: number;
  name: string;
  icon: string;
  color: string;
  type: 'income' | 'expense';
  is_default: number;
}

export interface Transaction {
  id: number;
  amount: number;
  description: string;
  category_id: number | null;
  date: string;
  type: 'income' | 'expense';
  recurring_id: number | null;
}

export interface RecurringTransaction {
  id: number;
  amount: number;
  description: string;
  category_id: number | null;
  type: 'income' | 'expense';
  frequency: 'daily' | 'weekly' | 'monthly' | 'yearly';
  start_date: string;
  end_date: string | null;
  next_due_date: string;
  active: number;
}

export interface AppSettings {
  theme: 'light' | 'dark';
}

export interface AppState {
  categories: Category[];
  transactions: Transaction[];
  recurring: RecurringTransaction[];
  settings: AppSettings;
  isLoading: boolean;
}

export type AppAction =
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'SET_CATEGORIES'; payload: Category[] }
  | { type: 'ADD_CATEGORY'; payload: Category }
  | { type: 'UPDATE_CATEGORY'; payload: Category }
  | { type: 'DELETE_CATEGORY'; payload: number }
  | { type: 'SET_TRANSACTIONS'; payload: Transaction[] }
  | { type: 'ADD_TRANSACTION'; payload: Transaction }
  | { type: 'UPDATE_TRANSACTION'; payload: Transaction }
  | { type: 'DELETE_TRANSACTION'; payload: number }
  | { type: 'SET_RECURRING'; payload: RecurringTransaction[] }
  | { type: 'ADD_RECURRING'; payload: RecurringTransaction }
  | { type: 'UPDATE_RECURRING'; payload: RecurringTransaction }
  | { type: 'DELETE_RECURRING'; payload: number }
  | { type: 'SET_SETTINGS'; payload: AppSettings }
  | { type: 'TOGGLE_THEME' };
