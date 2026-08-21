import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ScrollView, Alert } from 'react-native';
import { useTheme } from '../hooks/useTheme';
import { useCategories } from '../hooks/useCategories';
import { useRecurring } from '../hooks/useRecurring';
import { CategoryPicker } from '../components/CategoryPicker';
import { RecurringTransaction } from '../context/types';
import { useNavigation, useRoute } from '@react-navigation/native';
import { getCurrentDate } from '../utils/format';
import { RECURRING_FREQUENCIES } from '../utils/constants';
import Svg, { Path } from 'react-native-svg';

export function AddRecurringScreen() {
  const { colors } = useTheme();
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  const { categories } = useCategories();
  const { recurring, addRecurring, updateRecurring } = useRecurring();

  const recurringId = route.params?.recurringId;
  const [type, setType] = useState<'income' | 'expense'>('expense');
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');
  const [categoryId, setCategoryId] = useState<number | null>(null);
  const [frequency, setFrequency] = useState<'daily' | 'weekly' | 'monthly' | 'yearly'>('monthly');
  const [startDate, setStartDate] = useState(getCurrentDate());
  const [endDate, setEndDate] = useState('');

  useEffect(() => {
    if (recurringId) {
      const existing = recurring.find((r) => r.id === recurringId);
      if (existing) {
        setType(existing.type); setAmount(existing.amount.toString());
        setDescription(existing.description); setCategoryId(existing.category_id);
        setFrequency(existing.frequency); setStartDate(existing.start_date);
        setEndDate(existing.end_date || '');
      }
    }
  }, [recurringId, recurring]);

  const filteredCategories = categories.filter((c) => c.type === type);

  const handleSubmit = useCallback(async () => {
    const parsed = parseFloat(amount.replace(',', '.'));
    if (isNaN(parsed) || parsed <= 0) { Alert.alert('Errore', 'Inserisci un importo valido maggiore di zero.'); return; }
    const data = {
      amount: parsed, description: description.trim(), category_id: categoryId,
      type, frequency, start_date: startDate, end_date: endDate || null,
      next_due_date: startDate, active: 1,
    };
    if (recurringId) {
      const existing = recurring.find((r) => r.id === recurringId);
      if (existing) await updateRecurring({ ...existing, ...data });
    } else { await addRecurring(data); }
    navigation.goBack();
  }, [amount, description, categoryId, type, frequency, startDate, endDate, recurringId, recurring, addRecurring, updateRecurring, navigation]);

  return (
    <View style={[styles.container, { backgroundColor: 'transparent' }]}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Svg width={18} height={18} viewBox="0 0 24 24" fill="none">
            <Path d="M6 6l12 12M18 6L6 18" stroke={colors.text} strokeWidth={2} strokeLinecap="round" />
          </Svg>
        </TouchableOpacity>
        <Text style={[styles.title, { color: colors.text }]}>
          {recurringId ? 'Modifica' : 'Nuova Ricorrente'}
        </Text>
        <View style={{ width: 36 }} />
      </View>

      <ScrollView style={styles.scroll} contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
        {/* Type Toggle */}
        <View style={styles.typeToggle}>
          <TouchableOpacity
            style={[styles.typeBtn, type === 'expense' && { backgroundColor: colors.expense }, type !== 'expense' && { backgroundColor: colors.expenseSoft, borderColor: colors.expense + '30' }]}
            onPress={() => { setType('expense'); setCategoryId(null); }}
          >
            <Text style={{ color: type === 'expense' ? '#fff' : colors.textSecondary, fontFamily: '-apple-system', fontWeight: '700' }}>Uscita</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.typeBtn, type === 'income' && { backgroundColor: colors.income }, type !== 'income' && { backgroundColor: colors.incomeSoft, borderColor: colors.income + '30' }]}
            onPress={() => { setType('income'); setCategoryId(null); }}
          >
            <Text style={{ color: type === 'income' ? '#fff' : colors.textSecondary, fontFamily: '-apple-system', fontWeight: '700' }}>Entrata</Text>
          </TouchableOpacity>
        </View>

        {/* Amount */}
        <View style={[styles.section, { backgroundColor: colors.glass, borderColor: colors.glassBorder }]}>
          <Text style={[styles.label, { color: colors.glassTextSecondary }]}>Importo</Text>
          <View style={styles.amountRow}>
            <Text style={[styles.currency, { color: colors.textTertiary }]}>€</Text>
            <TextInput
              style={[styles.amountInput, { color: colors.text }]}
              value={amount}
              onChangeText={(text) => { const c = text.replace(',', '.'); if (c === '' || /^\d*\.?\d{0,2}$/.test(c)) setAmount(c); }}
              placeholder="0,00" placeholderTextColor={colors.textTertiary} keyboardType="decimal-pad"
            />
          </View>
        </View>

        {/* Description */}
        <View style={[styles.section, { backgroundColor: colors.glass, borderColor: colors.glassBorder }]}>
          <Text style={[styles.label, { color: colors.glassTextSecondary }]}>Descrizione</Text>
          <TextInput style={[styles.input, { color: colors.text }]} value={description} onChangeText={setDescription} placeholder="Es. Abbonamento Netflix" placeholderTextColor={colors.textTertiary} />
        </View>

        {/* Frequency */}
        <View style={[styles.section, { backgroundColor: colors.glass, borderColor: colors.glassBorder }]}>
          <Text style={[styles.label, { color: colors.glassTextSecondary }]}>Frequenza</Text>
          <View style={styles.freqRow}>
            {RECURRING_FREQUENCIES.map((f) => (
              <TouchableOpacity
                key={f.value}
                style={[styles.freqBtn, frequency === f.value && { backgroundColor: colors.primarySoft, borderColor: colors.primary }, frequency !== f.value && { borderColor: colors.glassBorder }]}
                onPress={() => setFrequency(f.value)}
              >
                <Text style={{ color: frequency === f.value ? colors.primary : colors.textSecondary, fontSize: 12, fontWeight: '600' }}>{f.label}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Dates */}
        <View style={[styles.section, { backgroundColor: colors.glass, borderColor: colors.glassBorder }]}>
          <Text style={[styles.label, { color: colors.glassTextSecondary }]}>Data Inizio</Text>
          <TextInput style={[styles.input, { color: colors.text }]} value={startDate} onChangeText={setStartDate} placeholder="AAAA-MM-GG" placeholderTextColor={colors.textTertiary} />
          <Text style={[styles.label, { color: colors.glassTextSecondary, marginTop: 12 }]}>Data Fine (opzionale)</Text>
          <TextInput style={[styles.input, { color: colors.text }]} value={endDate} onChangeText={setEndDate} placeholder="AAAA-MM-GG" placeholderTextColor={colors.textTertiary} />
        </View>

        {/* Category */}
        <View style={[styles.section, { backgroundColor: colors.glass, borderColor: colors.glassBorder }]}>
          <Text style={[styles.label, { color: colors.glassTextSecondary }]}>Categoria</Text>
          <CategoryPicker categories={filteredCategories} selectedId={categoryId} onSelect={(cat) => setCategoryId(cat.id)} />
        </View>

        {/* Submit */}
        <TouchableOpacity style={[styles.submitBtn, { backgroundColor: type === 'income' ? colors.income : colors.expense }]} activeOpacity={0.7} onPress={handleSubmit}>
          <Text style={styles.submitText}>{recurringId ? 'Aggiorna' : 'Salva'}</Text>
        </TouchableOpacity>

        <View style={{ height: 140 }} />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 16, paddingTop: 52, paddingBottom: 8 },
  backBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 17, fontWeight: '700', fontFamily: '-apple-system', letterSpacing: -0.2 },
  scroll: { flex: 1 },
  content: { padding: 16 },
  typeToggle: { flexDirection: 'row', marginBottom: 14, gap: 8, backgroundColor: 'rgba(120,120,128,0.08)', borderRadius: 16, padding: 3 },
  typeBtn: { flex: 1, paddingVertical: 10, borderRadius: 13, alignItems: 'center', borderWidth: 0 },
  section: { borderRadius: 18, borderWidth: 0.5, padding: 16, marginBottom: 10 },
  label: { fontSize: 12, fontWeight: '600', marginBottom: 8, fontFamily: '-apple-system', textTransform: 'uppercase', letterSpacing: 0.3 },
  amountRow: { flexDirection: 'row', alignItems: 'center' },
  currency: { fontSize: 24, fontWeight: '300', marginRight: 4 },
  amountInput: { fontSize: 28, fontWeight: '800', flex: 1, padding: 0, fontFamily: '-apple-system', letterSpacing: -0.5 },
  input: { fontSize: 15, padding: 0, fontFamily: '-apple-system' },
  freqRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  freqBtn: { paddingHorizontal: 14, paddingVertical: 8, borderRadius: 10, borderWidth: 0.5 },
  submitBtn: { paddingVertical: 16, borderRadius: 18, alignItems: 'center', marginTop: 8 },
  submitText: { fontSize: 15, fontWeight: '700', color: '#FFFFFF', fontFamily: '-apple-system' },
});
