import { AppState, AppAction } from './types';

export const initialState: AppState = {
  categories: [],
  transactions: [],
  recurring: [],
  settings: { theme: 'light' },
  isLoading: true,
};

export function appReducer(state: AppState, action: AppAction): AppState {
  switch (action.type) {
    case 'SET_LOADING':
      return { ...state, isLoading: action.payload };

    case 'SET_CATEGORIES':
      return { ...state, categories: action.payload };

    case 'ADD_CATEGORY':
      return { ...state, categories: [...state.categories, action.payload] };

    case 'UPDATE_CATEGORY':
      return {
        ...state,
        categories: state.categories.map((c) =>
          c.id === action.payload.id ? action.payload : c
        ),
      };

    case 'DELETE_CATEGORY':
      return {
        ...state,
        categories: state.categories.filter((c) => c.id !== action.payload),
      };

    case 'SET_TRANSACTIONS':
      return { ...state, transactions: action.payload };

    case 'ADD_TRANSACTION':
      return { ...state, transactions: [action.payload, ...state.transactions] };

    case 'UPDATE_TRANSACTION':
      return {
        ...state,
        transactions: state.transactions.map((t) =>
          t.id === action.payload.id ? action.payload : t
        ),
      };

    case 'DELETE_TRANSACTION':
      return {
        ...state,
        transactions: state.transactions.filter((t) => t.id !== action.payload),
      };

    case 'SET_RECURRING':
      return { ...state, recurring: action.payload };

    case 'ADD_RECURRING':
      return { ...state, recurring: [...state.recurring, action.payload] };

    case 'UPDATE_RECURRING':
      return {
        ...state,
        recurring: state.recurring.map((r) =>
          r.id === action.payload.id ? action.payload : r
        ),
      };

    case 'DELETE_RECURRING':
      return {
        ...state,
        recurring: state.recurring.filter((r) => r.id !== action.payload),
      };

    case 'SET_SETTINGS':
      return { ...state, settings: action.payload };

    case 'TOGGLE_THEME':
      return {
        ...state,
        settings: {
          ...state.settings,
          theme: state.settings.theme === 'light' ? 'dark' : 'light',
        },
      };

    default:
      return state;
  }
}
