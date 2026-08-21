import * as SQLite from 'expo-sqlite';

export async function executeSql(
  db: SQLite.SQLiteDatabase,
  sql: string,
  params: SQLite.SQLiteBindParams = []
): Promise<SQLite.SQLiteRunResult> {
  return await db.runAsync(sql, params);
}

export async function queryAll<T>(
  db: SQLite.SQLiteDatabase,
  sql: string,
  params: SQLite.SQLiteBindParams = []
): Promise<T[]> {
  return await db.getAllAsync<T>(sql, params);
}

export async function queryFirst<T>(
  db: SQLite.SQLiteDatabase,
  sql: string,
  params: SQLite.SQLiteBindParams = []
): Promise<T | null> {
  return await db.getFirstAsync<T>(sql, params);
}
