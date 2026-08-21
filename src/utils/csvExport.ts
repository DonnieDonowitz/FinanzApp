import { Platform } from 'react-native';
import * as Sharing from 'expo-sharing';
import * as FileSystem from 'expo-file-system';

interface CsvTransaction {
  id: number;
  amount: number;
  description: string;
  category_name: string;
  date: string;
  type: string;
}

export async function exportTransactionsToCsv(
  transactions: CsvTransaction[]
): Promise<void> {
  const header = 'Data,Tipo,Categoria,Descrizione,Importo\n';

  const rows = transactions
    .map((t) => {
      const type = t.type === 'income' ? 'Entrata' : 'Uscita';
      return `${t.date},${type},${t.category_name || 'Senza categoria'},"${t.description}",${t.amount.toFixed(2)}`;
    })
    .join('\n');

  const csvContent = header + rows;
  const fileName = `finanzapp_export_${new Date().toISOString().split('T')[0]}.csv`;

  if (Platform.OS === 'web') {
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = fileName;
    a.click();
    URL.revokeObjectURL(url);
    return;
  }

  // Native
  const fileUri = FileSystem.Paths.document.uri + fileName;
  const file = new FileSystem.File(fileUri);
  file.create();
  await file.write(csvContent);

  const isAvailable = await Sharing.isAvailableAsync();
  if (isAvailable) {
    await Sharing.shareAsync(fileUri, {
      mimeType: 'text/csv',
      dialogTitle: 'Esporta transazioni',
    });
  }
}
