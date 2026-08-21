import { File, Paths } from 'expo-file-system';
import * as Sharing from 'expo-sharing';
import * as DocumentPicker from 'expo-document-picker';
import * as SQLite from 'expo-sqlite';

const BACKUP_FILENAME = 'FinanzApp_backup.finanz';

function esc(val: any): string {
  if (val === null || val === undefined) return 'NULL';
  if (typeof val === 'number') return val.toString();
  const s = String(val);
  return "'" + s.replace(/'/g, "''") + "'";
}

function escInt(val: any): string {
  if (val === null || val === undefined) return 'NULL';
  return Math.floor(Number(val)).toString();
}

async function queryAll<T>(db: SQLite.SQLiteDatabase, sql: string): Promise<T[]> {
  return await db.getAllAsync<T>(sql);
}

async function buildBackupSQL(db: SQLite.SQLiteDatabase): Promise<string> {
  const categories = await queryAll<any>(db, 'SELECT * FROM categories ORDER BY id');
  const transactions = await queryAll<any>(db, 'SELECT * FROM transactions ORDER BY id');
  const recurring = await queryAll<any>(db, 'SELECT * FROM recurring_transactions ORDER BY id');
  const settings = await queryAll<any>(db, 'SELECT * FROM app_settings');

  const lines: string[] = [];
  const now = new Date().toISOString();

  lines.push('-- FinanzApp Backup');
  lines.push(`-- Generated: ${now}`);
  lines.push('-- App Version: 5.1.1');
  lines.push('');

  if (categories.length > 0) {
    lines.push('--- Categories ---');
    for (const row of categories) {
      lines.push(`INSERT INTO categories (id, name, icon, color, type, is_default) VALUES (${escInt(row.id)}, ${esc(row.name)}, ${esc(row.icon)}, ${esc(row.color)}, ${esc(row.type)}, ${escInt(row.is_default)});`);
    }
    lines.push('');
  }

  if (transactions.length > 0) {
    lines.push('--- Transactions ---');
    for (const row of transactions) {
      lines.push(`INSERT INTO transactions (id, amount, description, category_id, date, type, recurring_id) VALUES (${escInt(row.id)}, ${esc(row.amount)}, ${esc(row.description)}, ${escInt(row.category_id)}, ${esc(row.date)}, ${esc(row.type)}, ${escInt(row.recurring_id)});`);
    }
    lines.push('');
  }

  if (recurring.length > 0) {
    lines.push('--- Recurring Transactions ---');
    for (const row of recurring) {
      lines.push(`INSERT INTO recurring_transactions (id, amount, description, category_id, type, frequency, start_date, end_date, next_due_date, active) VALUES (${escInt(row.id)}, ${esc(row.amount)}, ${esc(row.description)}, ${escInt(row.category_id)}, ${esc(row.type)}, ${esc(row.frequency)}, ${esc(row.start_date)}, ${esc(row.end_date)}, ${esc(row.next_due_date)}, ${escInt(row.active)});`);
    }
    lines.push('');
  }

  if (settings.length > 0) {
    lines.push('--- Settings ---');
    for (const row of settings) {
      lines.push(`INSERT INTO app_settings (key, value) VALUES (${esc(row.key)}, ${esc(row.value)});`);
    }
    lines.push('');
  }

  return lines.join('\n');
}

export async function createBackup(db: SQLite.SQLiteDatabase): Promise<string> {
  const sql = await buildBackupSQL(db);
  const deleteStmts = `DELETE FROM transactions;\nDELETE FROM recurring_transactions;\nDELETE FROM categories;\nDELETE FROM app_settings;\n\n`;
  const content = `PRAGMA foreign_keys=OFF;\nBEGIN TRANSACTION;\n\n${deleteStmts}${sql}COMMIT;\nPRAGMA foreign_keys=ON;\n`;
  const file = new File(Paths.cache, BACKUP_FILENAME);
  file.create({ overwrite: true });
  file.write(content);
  return file.uri;
}

export async function exportBackup(fileUri: string): Promise<void> {
  const isAvailable = await Sharing.isAvailableAsync();
  if (!isAvailable) {
    throw new Error('La condivisione non è disponibile su questo dispositivo');
  }
  await Sharing.shareAsync(fileUri, {
    mimeType: 'application/octet-stream',
    dialogTitle: 'Condividi Backup FinanzApp',
  });
}

export async function pickBackupFile(): Promise<string> {
  const result = await DocumentPicker.getDocumentAsync({
    type: '*/*',
    copyToCacheDirectory: true,
  });
  if (result.canceled) throw new Error('Operazione annullata');
  const file = result.assets[0];
  return file.uri;
}

export async function readBackupFile(fileUri: string): Promise<string> {
  const file = new File(fileUri);
  return await file.text();
}

export async function executeBackupRestore(
  db: SQLite.SQLiteDatabase,
  sql: string
): Promise<void> {
  await db.execAsync(sql);
}
