import { Platform } from 'react-native';
import * as DocumentPicker from 'expo-document-picker';
import { File } from 'expo-file-system';
import type { SQLiteDatabase } from 'expo-sqlite';
import { Category } from '../context/types';

export interface ParsedRow {
  date: string;
  description: string;
  amount: number;
  type: 'income' | 'expense';
  category_id: number | null;
  /** Category name as written in the CSV (used for auto-creating missing categories) */
  category_name_raw: string | null;
}

export interface ImportResult {
  rows: ParsedRow[];
  /** Categories that were auto-created during import */
  createdCategories: CreatedCategory[];
  /** Rows whose category could not be matched and no category name was provided */
  unmatchedRows: number;
}

export interface CreatedCategory {
  id: number;
  name: string;
  color: string;
  type: 'income' | 'expense';
}

// ── Column name patterns ──────────────────────────────────────────────

const DATE_PATTERNS = [
  'data', 'date', 'data operazione', 'data valuta', 'data contabile',
  'dt.', 'dt operazione', 'fecha', 'valor', 'booking date', 'value date',
  'data transazione', 'data val',
];
const DESC_PATTERNS = [
  'descrizione', 'description', 'causale', 'dettaglio', 'descrizione operazione',
  'concepto', 'concept', 'motivo', 'oggetto', 'narrativa', 'details',
  'transaction details', 'reference', 'remittance', 'memo',
];
const AMOUNT_PATTERNS = [
  'importo', 'amount', 'importo movimento', 'importo (\u20ac)', 'importo euro',
  'euro', 'amount (eur)', 'movimento', 'quantit\u00e0', 'quantita', 'imp.',
  'betrag', 'importo totale', 'amount (gbp)', 'amount (usd)',
];
const TYPE_PATTERNS = [
  'tipo', 'type', 'segno', 'dare/avere', 'entrata/uscita', 'credit/debit',
  'c/d', 'd/c', 'natura', 'transaction type', 'direzione', 'verso',
];
const CATEGORY_PATTERNS = [
  'categoria', 'category', 'cat.', 'classificazione', 'tipologia',
  'category name', 'tipo spesa', 'budget category',
];

// ── Color palette for auto-created categories ────────────────────────

const CATEGORY_COLORS: Record<'income' | 'expense', string[]> = {
  expense: [
    '#6366F1', '#8B5CF6', '#A855F7', '#D946EF', '#EC4899',
    '#F43F5E', '#EF4444', '#F97316', '#F59E0B', '#EAB308',
    '#84CC16', '#22C55E', '#10B981', '#14B8A6', '#06B6D4',
    '#0EA5E9', '#3B82F6',
  ],
  income: [
    '#059669', '#0D9489', '#0891B2', '#2563EB', '#7C3AED',
    '#4F46E5', '#4338CA', '#0284C7',
  ],
};

// ── Helpers ───────────────────────────────────────────────────────────

function normalizeHeader(header: string): string {
  return header
    .toLowerCase()
    .trim()
    .replace(/["'()]/g, '')
    .replace(/[._]/g, ' ')
    .replace(/\s+/g, ' ');
}

function findColumn(headers: string[], patterns: string[]): number {
  for (const pattern of patterns) {
    const idx = headers.findIndex((h) => normalizeHeader(h).includes(pattern));
    if (idx !== -1) return idx;
  }
  return -1;
}

function parseDate(raw: string): string {
  const cleaned = raw.trim().replace(/["']/g, '');
  if (!cleaned) return '';

  // YYYY-MM-DD
  if (/^\d{4}-\d{2}-\d{2}/.test(cleaned)) {
    const d = cleaned.substring(0, 10);
    if (d >= '1900-01-01' && d <= '2100-12-31') return d;
    return '';
  }

  // DD/MM/YYYY or DD.MM.YYYY
  const itMatch = cleaned.match(/^(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{4})/);
  if (itMatch) {
    const [, day, month, year] = itMatch;
    const m = parseInt(month);
    const dd = parseInt(day);
    if (m >= 1 && m <= 12 && dd >= 1 && dd <= 31) {
      return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
    }
    return '';
  }

  // DD Mon YYYY (e.g. "15 gen 2025" or "15 January 2025")
  const monthMap: Record<string, string> = {
    gen: '01', jan: '01', feb: '02', febb: '02', mar: '03', apr: '04',
    mag: '05', may: '05', giu: '06', jun: '06', lug: '07', jul: '07',
    ago: '08', aug: '08', set: '09', sep: '09', ott: '10', oct: '10',
    nov: '11', dic: '12', dec: '12',
    january: '01', february: '02', march: '03', april: '04', june: '06',
    july: '07', august: '08', september: '09', october: '10',
    november: '11', december: '12',
  };
  const textMatch = cleaned.match(/^(\d{1,2})\s+([a-z\u00e0-\u00fa]+)\.?\s+(\d{4})/i);
  if (textMatch) {
    const [, day, mon, year] = textMatch;
    const monthNum = monthMap[mon.toLowerCase().substring(0, 3)];
    if (monthNum) {
      return `${year}-${monthNum}-${day.padStart(2, '0')}`;
    }
  }

  return '';
}

function parseAmount(raw: string): number {
  const cleaned = raw.trim().replace(/["']/g, '').replace(/\s/g, '');
  if (!cleaned) return 0;

  // Italian format: -1.234,56 or 1234,56
  if (/^-?\d{1,3}(\.\d{3})*,\d{1,2}$/.test(cleaned) || /^-?\d+,\d{1,2}$/.test(cleaned)) {
    return parseFloat(cleaned.replace(/\./g, '').replace(',', '.'));
  }
  // English format: -1,234.56 or 1234.56
  if (/^-?\d{1,3}(,\d{3})*\.\d{1,2}$/.test(cleaned) || /^-?\d+\.\d{1,2}$/.test(cleaned)) {
    return parseFloat(cleaned.replace(/,/g, ''));
  }
  // Plain
  const plain = parseFloat(cleaned.replace(',', '.'));
  return isNaN(plain) ? 0 : plain;
}

function parseType(raw: string, amount: number): 'income' | 'expense' {
  const cleaned = raw.trim().toLowerCase();
  if (
    ['entrata', 'credit', 'c', 'incasso', 'accredito', 'accrediti',
     'versamento', 'stipendio', 'bonifico in', 'rimborso', 'ricezione',
     'credit transfer', 'incoming', 'ricavo'].some((k) => cleaned.includes(k))
  ) return 'income';
  if (
    ['uscita', 'debit', 'd', 'pagamento', 'addebito', 'addebiti',
     'prelievo', 'bollettino', 'bonifico out', 'spesa',
     'debit transfer', 'outgoing', 'costo', 'cost'].some((k) => cleaned.includes(k))
  ) return 'expense';
  return amount >= 0 ? 'income' : 'expense';
}

/**
 * Try to match a description against known categories using keyword maps.
 * Returns the category id if found, null otherwise.
 *
 * Also used to match explicit category names from the CSV against existing ones.
 */
function guessCategoryByNameOrDescription(
  description: string,
  categories: Category[],
  categoryNameHint?: string,
): number | null {
  // 1) If a category name was explicitly provided, try to match it exactly first
  if (categoryNameHint) {
    const hint = categoryNameHint.trim().toLowerCase();
    const exact = categories.find((c) => c.name.toLowerCase() === hint);
    if (exact) return exact.id;

    // Partial match
    const partial = categories.find(
      (c) => hint.includes(c.name.toLowerCase()) || c.name.toLowerCase().includes(hint),
    );
    if (partial) return partial.id;
  }

  // 2) Keyword matching on description
  const desc = description.toLowerCase();
  const keywordMap: Record<string, string[]> = {
    'Supermercato': ['supermercato', 'supermarket', 'esselunga', 'conad', 'carrefour', 'lidl', 'penny', 'md', 'sisa', 'iper', 'auchan', 'despar', 'buma', 'todis', 'netto'],
    'Trasporti': ['carburante', 'benzina', 'diesel', 'fuel', 'q8', 'enip', 'enel x', 'esso', 'shell', 'tamoil', 'autogas', 'trenitalia', 'treno', 'atm', 'biglietto', 'uber', 'taxi', 'parcheggio', 'autostrada', 'telepass', 'unipolmove', 'nowmobility', 'italo', 'flixbus'],
    'Ristoranti': ['ristorante', 'pizzeria', 'caff\u00e8', 'cafe', 'mcdonald', 'burger king', 'kfc', 'starbucks', 'gelateria', 'trattoria', 'osteria', 'sushi', 'forneria', 'mensa', 'kebab', 'focaccia', 'rosticceria', 'pub'],
    'Abbonamenti': ['netflix', 'spotify', 'amazon prime', 'disney+', 'hulu', 'apple music', 'youtube', 'abbonamento', 'subscription', 'prime video', 'now tv', 'dazn', 'timvision', 'raiplay', 'mediaset infinity'],
    'Salute': ['farmacia', 'medico', 'ospedale', 'clinica', 'laboratorio', 'analisi', 'dentista', 'ottica', 'mutua', 'sanitaria', 'mutuo sanitario', 'specialista', 'terapia', 'fisioterapia'],
    'Bollette': ['enel', 'energia', 'elettricit\u00e0', 'gas', 'luce', 'acea', 'engie', 'edison', 'iren', 'hera', 'a2a', 'giardiniere', 'idrico', 'condominio', 'acqua', 'rifiuti', 'tari', 'trasporto rifiuti'],
    'Telefono e Internet': ['telefono', 'internet', 'tim', 'vodafone', 'wind', 'tre', 'iliad', 'fastweb', 'linkem', 'fibra', 'mobile', 'ricarica'],
    'Acquisti Online': ['amazon', 'ebay', 'zalando', 'aliexpress', 'asos', 'paypal', 'etsy', 'shein', 'temu', 'subito', 'vinted', 'idealista'],
    'Stipendio': ['stipendio', 'salario', 'paga', 'busta paga', 'cedolino', 'compenso', 'retribuzione', 'emolumenti'],
    'Sport': ['palestra', 'gym', 'fitness', 'sport', 'abbonamento palestra', 'fitpass', 'piscina', 'calcio', 'tennis'],
    'Intrattenimento': ['cinema', 'teatro', 'concerto', 'spettacolo', 'giochi', 'videogame', 'playstation', 'xbox', 'nintendo', 'steam'],
    'Abbigliamento': ['zara', 'h&m', 'primark', 'uno dei molti', 'negozio', 'abbigliamento', 'scarpe', 'boutique', 'outlet'],
    'Regali': ['regalo', 'gift', 'compleanno', 'natale', 'festa'],
    'Viaggi': ['hotel', 'airbnb', 'booking', 'volo', 'aeroporto', 'ryanair', 'easyjet', 'alitalia', 'air france', 'trivago', 'hostel'],
    'Educazione': ['libro', 'universit\u00e0', 'corso', 'formazione', 'scuola', 'mensile scolastico', 'tasse', 'iscrizione'],
    'Investimenti': ['investimento', 'azioni', 'etf', 'bond', 'titoli', 'broker', 'finecoin', 'degiro', 'interactive', 'trading', 'dividendo'],
    'Assicurazione': ['assicurazione', 'polizza', 'premio', 'inc sinistro', 'casa assicurazione', 'auto assicurazione'],
    'Bollo e Tasse': ['bollo', 'tassa', 'imposta', 'irpef', 'imu', 'tari', 'superbollo', 'visura', 'agenzia entrate', 'multa', 'violazione'],
    'Rimborsi': ['rimborso', 'reimbursement', 'rimb.', 'cashback', 'storno'],
    'Casa Manutenzione': ['manutenzione', 'idraulico', 'elettrico', 'fai da te', 'leroy mercastruttura', 'bricofer', 'brico', 'lavori casa', 'ristruttura', 'muratore'],
  };

  for (const [catName, keywords] of Object.entries(keywordMap)) {
    if (keywords.some((kw) => desc.includes(kw))) {
      const cat = categories.find((c) => c.name.toLowerCase() === catName.toLowerCase());
      if (cat) return cat.id;
    }
  }

  // 3) Try partial match on category names in the description
  for (const cat of categories) {
    if (cat.name.length > 3 && desc.includes(cat.name.toLowerCase())) return cat.id;
  }

  return null;
}

// ── CSV Parser ────────────────────────────────────────────────────────

function parseCsvContent(content: string): { headers: string[]; rows: string[][] } {
  const lines = content.split(/\r?\n/).filter((l) => l.trim().length > 0);
  if (lines.length < 2) {
    throw new Error('Il file CSV deve contenere almeno un\'intestazione e una riga di dati.');
  }

  // Detect delimiter
  const firstLine = lines[0];
  let delimiter = ',';
  if (firstLine.includes(';') && !firstLine.includes(',')) {
    delimiter = ';';
  } else if (firstLine.includes('\t') && !firstLine.includes(',')) {
    delimiter = '\t';
  } else if (!firstLine.includes(',') && !firstLine.includes(';')) {
    // Could be space-separated but very unusual — try to detect multi-column
    const commaCount = (firstLine.match(/,/g) || []).length;
    const semicolonCount = (firstLine.match(/;/g) || []).length;
    const tabCount = (firstLine.match(/\t/g) || []).length;
    if (tabCount > commaCount && tabCount > semicolonCount) delimiter = '\t';
    else if (semicolonCount > commaCount) delimiter = ';';
  }

  const parseLine = (line: string): string[] => {
    const result: string[] = [];
    let current = '';
    let inQuotes = false;
    for (let i = 0; i < line.length; i++) {
      const ch = line[i];
      if (ch === '"') {
        inQuotes = !inQuotes;
      } else if (ch === delimiter && !inQuotes) {
        result.push(current.trim());
        current = '';
      } else {
        current += ch;
      }
    }
    result.push(current.trim());
    return result;
  };

  const headers = parseLine(lines[0]);
  const rows = lines.slice(1).map(parseLine);

  return { headers, rows };
}

function parseHeaders(headers: string[], categories: Category[], rows: string[][]) {
  const dateCol = findColumn(headers, DATE_PATTERNS);
  const descCol = findColumn(headers, DESC_PATTERNS);
  const amountCol = findColumn(headers, AMOUNT_PATTERNS);
  const typeCol = findColumn(headers, TYPE_PATTERNS);
  const catCol = findColumn(headers, CATEGORY_PATTERNS);

  if (dateCol === -1) {
    throw new Error(
      'Colonna Data non trovata. Includi una colonna "Data" (o "Date", "Data Operazione").',
    );
  }
  if (descCol === -1) {
    throw new Error(
      'Colonna Descrizione non trovata. Includi una colonna "Descrizione" (o "Description", "Causale").',
    );
  }
  if (amountCol === -1) {
    throw new Error(
      'Colonna Importo non trovata. Includi una colonna "Importo" (o "Amount", "Euro").',
    );
  }

  // Validate: try first few rows to see if we get valid data
  let validTest = 0;
  for (let i = 0; i < Math.min(3, rows.length); i++) {
    const row = rows[i];
    if (row.length < Math.max(dateCol, descCol, amountCol) + 1) continue;
    if (parseDate(row[dateCol]) && parseAmount(row[amountCol])) {
      validTest++;
    }
  }
  if (validTest === 0 && rows.length > 0) {
    throw new Error(
      'Impossibile leggere dati validi. Verifica che il CSV abbia il formato:\n' +
      'Data; Descrizione; Importo; [Categoria]\n' +
      '2025-01-15; Spesa supermercato; -45,20; Alimentari',
    );
  }

  return { dateCol, descCol, amountCol, typeCol, catCol };
}

// ── Main parsing (without DB insertion) ──────────────────────────────

export async function pickAndParseCsv(categories: Category[]): Promise<ParsedRow[]> {
  const result = await DocumentPicker.getDocumentAsync({
    type: ['text/csv', 'text/comma-separated-values', 'application/csv', 'text/plain', '*/*'],
    copyToCacheDirectory: true,
  });

  if (result.canceled || !result.assets || result.assets.length === 0) {
    throw new Error('Nessun file selezionato.');
  }

  const file = result.assets[0];

  let content: string;
  if (Platform.OS === 'web') {
    const response = await fetch(file.uri);
    content = await response.text();
  } else {
    const f = new File(file.uri);
    content = await f.text();
  }

  if (!content || content.trim().length === 0) {
    throw new Error('Il file \u00e8 vuoto.');
  }

  const { headers, rows } = parseCsvContent(content);
  const { dateCol, descCol, amountCol, typeCol, catCol } = parseHeaders(headers, categories, rows);

  const results: ParsedRow[] = [];
  let unmatchedRows = 0;

  for (const row of rows) {
    if (row.length < Math.max(dateCol, descCol, amountCol) + 1) continue;

    const date = parseDate(row[dateCol]);
    if (!date) continue;

    const description = (row[descCol] || 'Importazione CSV').replace(/["']/g, '').trim();
    if (!description) continue;

    const rawAmount = parseAmount(row[amountCol]);
    if (rawAmount === 0) continue;

    let type: 'income' | 'expense';
    if (typeCol !== -1 && row[typeCol]) {
      type = parseType(row[typeCol], rawAmount);
    } else {
      type = rawAmount >= 0 ? 'income' : 'expense';
    }

    const amount = Math.abs(rawAmount);

    // Category: explicit from CSV column, then fallback to keyword matching
    let category_name_raw: string | null = null;
    let category_id: number | null = null;

    if (catCol !== -1 && row[catCol]) {
      category_name_raw = row[catCol].replace(/["']/g, '').trim() || null;
      if (category_name_raw) {
        // Try to match against existing categories
        category_id = guessCategoryByNameOrDescription(description, categories, category_name_raw);
      }
    }

    if (category_id === null) {
      category_id = guessCategoryByNameOrDescription(description, categories);
    }

    if (category_id === null && category_name_raw === null) {
      unmatchedRows++;
    }

    results.push({ date, description, amount, type, category_id, category_name_raw });
  }

  if (results.length === 0) {
    throw new Error('Nessuna transazione valida trovata nel file. Verifica il formato del CSV.');
  }

  return results;
}

// ── Full import with auto-category creation and DB insertion ──────────

/**
 * High-level import flow:
 * 1. Pick and parse CSV file
 * 2. Auto-create any missing categories
 * 3. Insert all transactions into the database
 * 4. Update the Redux state
 */
export async function executeImport(
  categories: Category[],
  db: SQLiteDatabase,
  addTransactionToState: (tx: { amount: number; description: string; category_id: number | null; date: string; type: 'income' | 'expense' }) => Promise<void>,
  addCategoryToState: (category: Omit<Category, 'id'> & { is_default?: number }) => Promise<Category>,
): Promise<ImportResult> {
  const rows = await pickAndParseCsv(categories);

  // Figure out which categories need to be created
  const createdCategories: CreatedCategory[] = [];
  const newCategoryColorIndex: Record<'income' | 'expense', number> = { expense: 0, income: 0 };

  // Get refreshed category list after each creation so guessCategoryByNameOrDescription works
  let currentCategories = [...categories];

  const resolvedRows = await Promise.all(
    rows.map(async (row): Promise<ParsedRow> => {
      if (row.category_id !== null) return row; // already matched
      if (!row.category_name_raw) return row;    // no category name provided

      // Check again if category exists (maybe it was just created)
      const existing = guessCategoryByNameOrDescription(row.description, currentCategories, row.category_name_raw);
      if (existing !== null) {
        return { ...row, category_id: existing };
      }

      // Auto-create the new category
      const type = row.type;
      const colorList = CATEGORY_COLORS[type];
      const color = colorList[newCategoryColorIndex[type] % colorList.length];
      newCategoryColorIndex[type]++;

      const newCat = await addCategoryToState({
        name: row.category_name_raw,
        icon: type === 'income' ? 'add-circle' : 'ellipsis-horizontal',
        color,
        type,
        is_default: 0,
      });

      const createdCat: CreatedCategory = { id: newCat.id, name: newCat.name, color: newCat.color, type };
      createdCategories.push(createdCat);
      currentCategories = [...currentCategories, newCat];

      return { ...row, category_id: newCat.id };
    }),
  );

  // Now insert all transactions
  for (const row of resolvedRows) {
    await addTransactionToState({
      amount: row.amount,
      description: row.description,
      category_id: row.category_id,
      date: row.date,
      type: row.type,
    });
  }

  const unmatchedRows = resolvedRows.filter((r) => r.category_id === null).length;

  return { rows: resolvedRows, createdCategories, unmatchedRows };
}

/** Return a sample CSV string the user can download/copy */
export function getSampleCsvFormat(): string {
  return (
    'Data,Descrizione,Importo,Categoria,Tipo\n' +
    '2025-01-15,Spesa al supermercato Conad,-45.20,Alimentari,Uscita\n' +
    '2025-01-16,Benzina IP,-60.00,Trasporti,Uscita\n' +
    '2025-01-18,Pagamento Netflix,-15.99,Abbonamenti,Uscita\n' +
    '2025-01-20,Stipendio Gennaio,2500.00,Stipendio,Entrata\n' +
    '2025-01-22,Ristorante Pizza,-28.50,Ristoranti,Uscita\n' +
    '2025-01-25,Palestra mensile,-35.00,Sport,Uscita\n' +
    '2025-01-28,Bolletta Enel,-85.00,Bollette,Uscita\n' +
    '2025-02-01,Acquisto Amazon,-32.90,Acquisti Online,Uscita\n' +
    '2025-02-03,Farmacia Tachipirina,-12.50,Salute,Uscita\n' +
    '2025-02-10,Stipendio Febbraio,2500.00,Stipendio,Entrata'
  );
}

/**
 * Return a human-readable format guide (for showing in the UI).
 */
export function getFormatGuide(): string {
  return (
    'Formato CSV supportato\n' +
    '\n' +
    'Colonne richieste (in qualsiasi ordine):\n' +
    '\u2022 Data — formato: YYYY-MM-DD, DD/MM/YYYY o DD.MM.YYYY\n' +
    '\u2022 Descrizione — testo della transazione\n' +
    '\u2022 Importo — numeri positivi (entrata) o negativi (uscita)\n' +
    '\n' +
    'Colonne opzionali:\n' +
    '\u2022 Categoria — nome della categoria (es. "Trasporti"). Se non esiste viene creata automaticamente\n' +
    '\u2022 Tipo — "Entrata" o "Uscita" (rilevato automaticamente dall\'importo)\n' +
    '\n' +
    'Separatori supportati: virgola (,), punto e virgola (;), tabulazione\n' +
    'Codifica: UTF-8\n' +
    '\n' +
    'Esempio:\n' +
    'Data;Descrizione;Importo;Categoria;Tipo\n' +
    '2025-01-15;Spesa Conad;-45,20;Alimentari;Uscita\n' +
    '2025-01-20;Stipendio;2500,00;Stipendio;Entrata'
  );
}
