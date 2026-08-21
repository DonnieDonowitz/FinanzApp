export function getNextDueDate(
  currentDueDate: string,
  frequency: 'daily' | 'weekly' | 'monthly' | 'yearly'
): string {
  const date = new Date(currentDueDate + 'T00:00:00');

  switch (frequency) {
    case 'daily':
      date.setDate(date.getDate() + 1);
      break;
    case 'weekly':
      date.setDate(date.getDate() + 7);
      break;
    case 'monthly':
      date.setMonth(date.getMonth() + 1);
      break;
    case 'yearly':
      date.setFullYear(date.getFullYear() + 1);
      break;
  }

  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

export function isDue(nextDueDate: string): boolean {
  const today = new Date();
  const todayStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;
  return nextDueDate <= todayStr;
}

export function getFrequencyLabel(frequency: string): string {
  switch (frequency) {
    case 'daily': return 'Giornaliero';
    case 'weekly': return 'Settimanale';
    case 'monthly': return 'Mensile';
    case 'yearly': return 'Annuale';
    default: return frequency;
  }
}
