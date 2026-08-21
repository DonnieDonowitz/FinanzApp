export const EXPENSE_CATEGORIES: { name: string; color: string }[] = [
  { name: 'Alimentari', color: '#E53935' },
  { name: 'Trasporti', color: '#1E88E5' },
  { name: 'Abitazione', color: '#8E24AA' },
  { name: 'Salute', color: '#D81B60' },
  { name: 'Intrattenimento', color: '#FB8C00' },
  { name: 'Abbigliamento', color: '#00ACC1' },
  { name: 'Educazione', color: '#43A047' },
  { name: 'Ristoranti', color: '#F4511E' },
  { name: 'Bollette', color: '#5E35B1' },
  { name: 'Altro', color: '#757575' },
];

export const INCOME_CATEGORIES: { name: string; color: string }[] = [
  { name: 'Stipendio', color: '#2E7D32' },
  { name: 'Freelance', color: '#00838F' },
  { name: 'Investimenti', color: '#1565C0' },
  { name: 'Altro', color: '#6A1B9A' },
];

export const RECURRING_FREQUENCIES = [
  { value: 'daily', label: 'Giornaliero' },
  { value: 'weekly', label: 'Settimanale' },
  { value: 'monthly', label: 'Mensile' },
  { value: 'yearly', label: 'Annuale' },
] as const;

export const TRANSACTION_FILTERS = [
  { value: 'all', label: 'Tutti' },
  { value: 'income', label: 'Entrate' },
  { value: 'expense', label: 'Uscite' },
] as const;

export const CATEGORY_ICONS: Record<string, string> = {
  Alimentari: '🛒', Spesa: '🛒',
  Trasporti: '⛽', Carburante: '⛽',
  Abitazione: '🏠', Casa: '🏠', Affitto: '🏠',
  Salute: '🏥', Medicina: '🏥',
  Intrattenimento: '🎬', Svago: '🎬', Netflix: '🎬',
  Abbigliamento: '👕',
  Educazione: '📚', Scuola: '📚',
  Ristoranti: '🍝', 'Cena fuori': '🍝',
  Bollette: '⚡', Energia: '⚡',
  Stipendio: '💼', Lavoro: '💼',
  Freelance: '💻',
  Investimenti: '📈', Investimento: '📈',
  Altro: '📦',
  Palestra: '🏋️', Sport: '🏋️',
  'Spotify Family': '🎵', Musica: '🎵',
  'iCloud+ 200GB': '☁️', Cloud: '☁️',
  'Il Post — abbonamento': '📰',
  'Q8 Distributore': '⛽',
};

export function categoryIcon(name: string): string {
  return CATEGORY_ICONS[name] || '📌';
}
