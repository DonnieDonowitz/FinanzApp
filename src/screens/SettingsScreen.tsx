import React, { useCallback, useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity,
  Switch, Alert, Modal, FlatList, Share, Platform,
} from 'react-native';
import { useTheme } from '../hooks/useTheme';
import { useTransactions } from '../hooks/useTransactions';
import { useCategories } from '../hooks/useCategories';
import { exportTransactionsToCsv } from '../utils/csvExport';
import { executeImport, ImportResult, getSampleCsvFormat, getFormatGuide } from '../utils/csvImport';
import { useNavigation } from '@react-navigation/native';
import { formatCurrency, formatDate, FONT_MONO } from '../utils/format';
import Svg, { Path, Circle } from 'react-native-svg';
import { useAppContext } from '../context/AppContext';
import { Category } from '../context/types';
import { GlassView } from '../components/GlassView';
import { AppLogo } from '../components/AppLogo';
import { createBackup, exportBackup, pickBackupFile, readBackupFile, executeBackupRestore } from '../utils/backup';

export function SettingsScreen() {
  const { colors, theme, toggleTheme } = useTheme();
  const navigation = useNavigation<any>();
  const { db, refreshData } = useAppContext();
  const { transactions, addTransaction } = useTransactions();
  const { categories, addCategory } = useCategories();

  const [previewVisible, setPreviewVisible] = useState(false);
  const [importResult, setImportResult] = useState<ImportResult | null>(null);
  const [importing, setImporting] = useState(false);
  const [formatGuideVisible, setFormatGuideVisible] = useState(false);
  const [backupLoading, setBackupLoading] = useState(false);

  const handleExportCsv = useCallback(async () => {
    if (transactions.length === 0) {
      Alert.alert('Nessun dato', 'Non ci sono transazioni da esportare.');
      return;
    }
    const csvData = transactions.map((t) => ({
      id: t.id, amount: t.amount, description: t.description,
      category_name: categories.find((c) => c.id === t.category_id)?.name || 'Senza categoria',
      date: t.date, type: t.type,
    }));
    await exportTransactionsToCsv(csvData);
  }, [transactions, categories]);

  const handleImportCsv = useCallback(async () => {
    if (!db) return;
    setImporting(true);
    try {
      const addCat = async (cat: Omit<Category, 'id'> & { is_default?: number }): Promise<Category> => {
        const result = await addCategory(cat);
        if (!result) throw new Error('Failed to create category');
        return result;
      };
      const addTx = async (tx: { amount: number; description: string; category_id: number | null; date: string; type: 'income' | 'expense' }): Promise<void> => {
        await addTransaction(tx);
      };
      const result = await executeImport(categories, db, addTx, addCat);
      setImportResult(result);
      setPreviewVisible(true);
    } catch (error: any) {
      if (error.message && !error.message.includes('Nessun file')) {
        Alert.alert('Errore', error.message || 'Impossibile leggere il file.');
      }
    } finally {
      setImporting(false);
    }
  }, [categories, db, addTransaction, addCategory]);

  const handleConfirmImport = useCallback(async () => {
    setPreviewVisible(false);
    if (!importResult) return;
    const parts: string[] = [`${importResult.rows.length} transazioni importate con successo.`];
    if (importResult.createdCategories.length > 0) {
      parts.push(`\nCategorie create: ${importResult.createdCategories.map((c) => c.name).join(', ')}`);
    }
    if (importResult.unmatchedRows > 0) {
      parts.push(`\n${importResult.unmatchedRows} transazioni senza categoria.`);
    }
    Alert.alert('Importazione completata', parts.join(''));
    setImportResult(null);
    await refreshData();
  }, [importResult, refreshData]);

  const handleShareSampleCsv = useCallback(async () => {
    try {
      await Share.share({ message: getSampleCsvFormat(), title: 'Formato CSV FinanzApp' });
    } catch { /* noop */ }
  }, []);

  const handleCreateBackup = useCallback(async () => {
    if (!db || backupLoading) return;
    setBackupLoading(true);
    try {
      const fileUri = await createBackup(db);
      await exportBackup(fileUri);
    } catch (err: any) {
      if (err.message !== 'Operazione annullata') {
        Alert.alert('Errore', err.message || 'Impossibile creare il backup');
      }
    } finally {
      setBackupLoading(false);
    }
  }, [db, backupLoading]);

  const handleRestoreBackup = useCallback(async () => {
    if (!db || backupLoading) return;
    setBackupLoading(true);
    try {
      const fileUri = await pickBackupFile();
      const sql = await readBackupFile(fileUri);
      await new Promise<void>((resolve, reject) => {
        Alert.alert(
          'Ripristina Backup',
          'Tutti i dati correnti verranno sostituiti con quelli del backup. Continuare?',
          [
            { text: 'Annulla', style: 'cancel', onPress: () => { setBackupLoading(false); reject(new Error('Operazione annullata')); } },
            {
              text: 'Ripristina', style: 'destructive', onPress: async () => {
                try {
                  await executeBackupRestore(db, sql);
                  await refreshData();
                  Alert.alert('Completato', 'Backup ripristinato con successo.');
                  resolve();
                } catch (e: any) {
                  reject(e);
                }
              },
            },
          ]
        );
      });
    } catch (err: any) {
      if (err.message !== 'Operazione annullata') {
        Alert.alert('Errore', err.message || 'Impossibile ripristinare il backup');
      }
    } finally {
      setBackupLoading(false);
    }
  }, [db, backupLoading, refreshData]);

  const renderPreviewItem = useCallback(
    ({ item }: { item: { date: string; description: string; amount: number; type: 'income' | 'expense'; category_id: number | null } }) => {
      const catName = item.category_id ? categories.find((c) => c.id === item.category_id)?.name || 'Altro' : null;
      const isNew = item.category_id !== null && !categories.some((c) => c.id === item.category_id);
      return (
        <View style={[styles.previewRow, { borderBottomColor: colors.divider }]}>
          <View style={styles.previewLeft}>
              <Text style={[styles.previewDesc, { color: colors.glassText }]} numberOfLines={1}>{item.description}</Text>
              <Text style={[styles.previewMeta, { color: colors.glassTextTertiary }]}>
                {formatDate(item.date)}{catName ? ` · ${catName}` : ' · Senza categoria'}
                {isNew && <Text style={{ color: colors.primary }}> (nuova)</Text>}
              </Text>
          </View>
          <Text style={[styles.previewAmount, { color: item.type === 'income' ? colors.income : colors.expense }]}>
            {item.type === 'income' ? '+' : '−'}{formatCurrency(item.amount)}
          </Text>
        </View>
      );
    }, [categories, colors]);

  return (
    <View style={[styles.container, { backgroundColor: 'transparent' }]}>
      <ScrollView showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <Text style={[styles.title, { color: colors.text }]}>Impostazioni</Text>
        </View>

        {/* Aspetto */}
        <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>Aspetto</Text>
        <GlassView intensity="regular" style={styles.card} borderRadius={18}>
          <View style={styles.settingRow}>
            <Text style={styles.settingEmoji}>🌙</Text>
            <Text style={[styles.settingLabel, { color: colors.glassText }]}>Tema Scuro</Text>
            <Switch
              value={theme === 'dark'}
              onValueChange={toggleTheme}
              trackColor={{ false: colors.inputBg, true: colors.primary + '50' }}
              thumbColor={theme === 'dark' ? colors.primary : '#f4f3f4'}
            />
          </View>
        </GlassView>

        {/* Gestione Dati */}
        <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>Gestione</Text>
        <GlassView intensity="regular" style={styles.card} borderRadius={18}>
          <TouchableOpacity style={styles.settingRow} activeOpacity={0.6} onPress={() => navigation.navigate('ManageCategories')}>
            <Text style={styles.settingEmoji}>🏷️</Text>
            <Text style={[styles.settingLabel, { color: colors.glassText }]}>Categorie</Text>
            <Svg width={16} height={16} viewBox="0 0 24 24" fill="none">
              <Path d="M9 6l6 6-6 6" stroke={colors.textTertiary} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
            </Svg>
          </TouchableOpacity>
          <View style={[styles.divider, { backgroundColor: colors.divider }]} />
          <TouchableOpacity style={styles.settingRow} activeOpacity={0.6} onPress={() => navigation.navigate('Statistics')}>
            <Text style={styles.settingEmoji}>📊</Text>
            <Text style={[styles.settingLabel, { color: colors.glassText }]}>Statistiche</Text>
            <Svg width={16} height={16} viewBox="0 0 24 24" fill="none">
              <Path d="M9 6l6 6-6 6" stroke={colors.textTertiary} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
            </Svg>
          </TouchableOpacity>
          <View style={[styles.divider, { backgroundColor: colors.divider }]} />
          <TouchableOpacity style={styles.settingRow} activeOpacity={0.6} onPress={() => navigation.getParent()?.navigate('Ricorrenti')}>
            <Text style={styles.settingEmoji}>🔄</Text>
            <Text style={[styles.settingLabel, { color: colors.glassText }]}>Transazioni Ricorrenti</Text>
            <Svg width={16} height={16} viewBox="0 0 24 24" fill="none">
              <Path d="M9 6l6 6-6 6" stroke={colors.textTertiary} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
            </Svg>
          </TouchableOpacity>
        </GlassView>

        {/* Importa / Esporta */}
        <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>Dati</Text>
        <GlassView intensity="regular" style={styles.card} borderRadius={18}>
          <TouchableOpacity style={styles.settingRow} activeOpacity={0.6} onPress={handleImportCsv} disabled={importing}>
            <Text style={styles.settingEmoji}>📥</Text>
            <Text style={[styles.settingLabel, { color: importing ? colors.glassTextTertiary : colors.glassText }]}>
              {importing ? 'Importazione...' : 'Importa da CSV'}
            </Text>
            <Svg width={16} height={16} viewBox="0 0 24 24" fill="none">
              <Path d="M9 6l6 6-6 6" stroke={colors.textTertiary} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
            </Svg>
          </TouchableOpacity>
          <View style={[styles.divider, { backgroundColor: colors.divider }]} />
          <TouchableOpacity style={styles.settingRow} activeOpacity={0.6} onPress={handleExportCsv}>
            <Text style={styles.settingEmoji}>📤</Text>
            <Text style={[styles.settingLabel, { color: colors.glassText }]}>Esporta CSV</Text>
            <Svg width={16} height={16} viewBox="0 0 24 24" fill="none">
              <Path d="M9 6l6 6-6 6" stroke={colors.textTertiary} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
            </Svg>
          </TouchableOpacity>
          <View style={[styles.divider, { backgroundColor: colors.divider }]} />
          <TouchableOpacity style={styles.settingRow} activeOpacity={0.6} onPress={() => setFormatGuideVisible(true)}>
            <Text style={styles.settingEmoji}>📋</Text>
            <Text style={[styles.settingLabel, { color: colors.glassText }]}>Formato CSV</Text>
            <Svg width={16} height={16} viewBox="0 0 24 24" fill="none">
              <Circle cx="12" cy="12" r="9" stroke={colors.textTertiary} strokeWidth={1.6} />
              <Path d="M12 16v-1" stroke={colors.textTertiary} strokeWidth={1.6} strokeLinecap="round" />
              <Path d="M12 12V9a2 2 0 00-2-2" stroke={colors.textTertiary} strokeWidth={1.6} strokeLinecap="round" />
            </Svg>
          </TouchableOpacity>
        </GlassView>
        <Text style={[styles.hint, { color: colors.textTertiary }]}>
          Supporta CSV da banche italiane. Le categorie mancanti vengono create automaticamente.
        </Text>

        {/* Backup */}
        <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>Backup</Text>
        <GlassView intensity="regular" style={styles.card} borderRadius={18}>
          <TouchableOpacity style={styles.settingRow} activeOpacity={0.6} onPress={handleCreateBackup} disabled={backupLoading}>
            <Text style={styles.settingEmoji}>💾</Text>
            <Text style={[styles.settingLabel, { color: backupLoading ? colors.glassTextTertiary : colors.glassText }]}>
              {backupLoading ? 'Creazione...' : 'Crea Backup'}
            </Text>
          </TouchableOpacity>
          <View style={[styles.divider, { backgroundColor: colors.divider }]} />
          <TouchableOpacity style={styles.settingRow} activeOpacity={0.6} onPress={handleRestoreBackup} disabled={backupLoading}>
            <Text style={styles.settingEmoji}>📂</Text>
            <Text style={[styles.settingLabel, { color: backupLoading ? colors.glassTextTertiary : colors.glassText }]}>
              {backupLoading ? 'Ripristino...' : 'Ripristina Backup'}
            </Text>
          </TouchableOpacity>
        </GlassView>
        <Text style={[styles.hint, { color: colors.textTertiary }]}>
          I backup hanno estensione .finanz e contengono categorie, transazioni, ricorrenti e impostazioni.
        </Text>

        {/* Info */}
        <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>Info</Text>
        <GlassView intensity="regular" style={styles.card} borderRadius={18}>
          <View style={styles.settingRow}>
            <Text style={styles.settingEmoji}>📱</Text>
            <Text style={[styles.settingLabel, { color: colors.glassText }]}>Versione</Text>
            <Text style={[styles.settingValue, { color: colors.glassTextSecondary }]}>5.1.1</Text>
          </View>
          <View style={[styles.divider, { backgroundColor: colors.divider }]} />
          <AppLogo />
        </GlassView>

        <View style={{ height: 100 }} />
      </ScrollView>

      {/* Import Result Modal */}
      <Modal visible={previewVisible} animationType="slide" presentationStyle="pageSheet"
        onRequestClose={() => { setPreviewVisible(false); setImportResult(null); }}>
        <View style={[styles.modalContainer, { backgroundColor: colors.bg }]}>
          <View style={[styles.modalHeader, { borderBottomColor: colors.divider }]}>
            <TouchableOpacity onPress={() => { setPreviewVisible(false); setImportResult(null); }} style={styles.modalBtn} activeOpacity={0.6}>
              <Text style={[styles.modalBtnText, { color: colors.primary }]}>Chiudi</Text>
            </TouchableOpacity>
            <Text style={[styles.modalTitle, { color: colors.glassText }]}>Importate ({importResult?.rows.length ?? 0})</Text>
            <TouchableOpacity onPress={handleConfirmImport} style={styles.modalBtn} activeOpacity={0.6}>
              <Text style={[styles.modalBtnText, { color: colors.primary }]}>OK</Text>
            </TouchableOpacity>
          </View>
          {importResult && (
            <View style={[styles.summaryBanner, { backgroundColor: colors.sectionBg }]}>
              <Text style={[styles.summaryText, { color: colors.glassText }]}>{importResult.rows.length} transazioni importate</Text>
              {importResult.createdCategories.length > 0 && (
                <View style={styles.createdCats}>
                  <Text style={[styles.createdCatsLabel, { color: colors.glassTextSecondary }]}>Categorie create:</Text>
                  {importResult.createdCategories.map((cat) => (
                    <View key={cat.id} style={styles.createdCatChip}>
                      <View style={[styles.createdCatDot, { backgroundColor: cat.color }]} />
                      <Text style={[styles.createdCatName, { color: colors.glassText }]}>{cat.name}</Text>
                    </View>
                  ))}
                </View>
              )}
              {importResult.unmatchedRows > 0 && (
                <Text style={[styles.unmatchedText, { color: colors.warning }]}>
                  {importResult.unmatchedRows} transazioni senza categoria
                </Text>
              )}
            </View>
          )}
          <FlatList data={importResult?.rows ?? []} keyExtractor={(_, i) => i.toString()} renderItem={renderPreviewItem} style={styles.previewList} />
        </View>
      </Modal>

      {/* Format Guide Modal */}
      <Modal visible={formatGuideVisible} animationType="slide" presentationStyle="pageSheet"
        onRequestClose={() => setFormatGuideVisible(false)}>
        <View style={[styles.modalContainer, { backgroundColor: colors.bg }]}>
          <View style={[styles.modalHeader, { borderBottomColor: colors.divider }]}>
            <View style={styles.modalBtn} />
            <Text style={[styles.modalTitle, { color: colors.glassText }]}>Formato CSV</Text>
            <TouchableOpacity onPress={() => setFormatGuideVisible(false)} style={styles.modalBtn} activeOpacity={0.6}>
              <Text style={[styles.modalBtnText, { color: colors.primary }]}>Chiudi</Text>
            </TouchableOpacity>
          </View>
          <ScrollView style={styles.guideScroll}>
              <Text style={[styles.guideText, { color: colors.glassText }]}>{getFormatGuide()}</Text>
            <Text style={[styles.guideSectionTitle, { color: colors.glassText }]}>Esempio CSV</Text>
            <GlassView intensity="regular" style={styles.codeBlock} borderRadius={12}>
              <Text style={[styles.codeText, { color: colors.glassTextSecondary }]}>{getSampleCsvFormat()}</Text>
            </GlassView>
            <TouchableOpacity style={[styles.shareSampleBtn, { backgroundColor: colors.primary }]} activeOpacity={0.6} onPress={handleShareSampleCsv}>
              <Text style={styles.shareSampleBtnText}>Condividi esempio CSV</Text>
            </TouchableOpacity>
            <Text style={[styles.guideNote, { color: colors.textTertiary }]}>
              Suggerimento: esporta prima un CSV dalla tua banca, poi aprilo con un editor di testo per verificare il formato.
            </Text>
            <View style={{ height: 40 }} />
          </ScrollView>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingHorizontal: 24, paddingTop: 52, paddingBottom: 4 },
  title: { fontSize: 26, fontWeight: '700', fontFamily: '-apple-system', letterSpacing: -0.5 },
  sectionTitle: { fontSize: 11, fontWeight: '700', textTransform: 'uppercase', letterSpacing: 0.8, paddingHorizontal: 16, marginBottom: 6, marginTop: 16, fontFamily: '-apple-system' },
  card: { marginHorizontal: 16, marginBottom: 10 },
  settingRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 16, paddingVertical: 13, gap: 12 },
  settingEmoji: { fontSize: 18 },
  settingLabel: { fontSize: 15, fontWeight: '500', fontFamily: '-apple-system', flex: 1 },
  settingValue: { fontSize: 14, fontFamily: '-apple-system' },
  rowLeft: { flexDirection: 'row', alignItems: 'center', flex: 1 },
  divider: { height: 0.5, marginLeft: 16 },
  hint: { fontSize: 11, fontFamily: '-apple-system', paddingHorizontal: 20, marginTop: 6, lineHeight: 15 },
  modalContainer: { flex: 1 },
  modalHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 16, paddingTop: 52, paddingBottom: 12, borderBottomWidth: 0.5 },
  modalTitle: { fontSize: 17, fontWeight: '700', fontFamily: '-apple-system' },
  modalBtn: { minWidth: 60, alignItems: 'center' },
  modalBtnText: { fontSize: 16, fontWeight: '600', fontFamily: '-apple-system' },
  summaryBanner: { paddingHorizontal: 16, paddingVertical: 12 },
  summaryText: { fontSize: 15, fontWeight: '700', fontFamily: '-apple-system' },
  createdCats: { marginTop: 8 },
  createdCatsLabel: { fontSize: 12, fontWeight: '600', fontFamily: '-apple-system', marginBottom: 4 },
  createdCatChip: { flexDirection: 'row', alignItems: 'center', marginVertical: 2 },
  createdCatDot: { width: 8, height: 8, borderRadius: 4, marginRight: 6 },
  createdCatName: { fontSize: 13, fontWeight: '600', fontFamily: '-apple-system' },
  unmatchedText: { fontSize: 12, fontWeight: '600', fontFamily: '-apple-system', marginTop: 6 },
  previewList: { flex: 1 },
  previewRow: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingVertical: 10, borderBottomWidth: 0.5 },
  previewLeft: { flex: 1, marginRight: 12 },
  previewDesc: { fontSize: 14, fontWeight: '500', fontFamily: '-apple-system' },
  previewMeta: { fontSize: 11, fontFamily: '-apple-system', marginTop: 2 },
  previewAmount: { fontSize: 14, fontWeight: '700', fontFamily: '-apple-system' },
  guideScroll: { flex: 1, paddingHorizontal: 16 },
  guideText: { fontSize: 14, fontFamily: '-apple-system', lineHeight: 22, marginTop: 16 },
  guideSectionTitle: { fontSize: 16, fontWeight: '700', fontFamily: '-apple-system', marginTop: 24, marginBottom: 8 },
  codeBlock: { padding: 12 },
  codeText: { fontSize: 12, fontFamily: FONT_MONO, lineHeight: 18 },
  shareSampleBtn: { marginTop: 16, paddingVertical: 12, borderRadius: 14, alignItems: 'center' },
  shareSampleBtnText: { color: '#fff', fontSize: 14, fontWeight: '700', fontFamily: '-apple-system' },
  guideNote: { fontSize: 12, fontFamily: '-apple-system', lineHeight: 18, marginTop: 16 },
});
