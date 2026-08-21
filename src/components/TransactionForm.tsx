import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Platform,
  Alert,
  KeyboardAvoidingView,
} from 'react-native';
import DateTimePicker, { DateTimePickerEvent } from '@react-native-community/datetimepicker';
import { Transaction, Category } from '../context/types';
import { useTheme } from '../hooks/useTheme';
import { CategoryPicker } from './CategoryPicker';
import { getCurrentDate } from '../utils/format';
import Svg, { Path, Rect, Line } from 'react-native-svg';

interface TransactionFormProps {
  transaction?: Transaction | null;
  categories: Category[];
  type: 'income' | 'expense';
  onTypeChange?: (type: 'income' | 'expense') => void;
  onSubmit: (data: {
    amount: number;
    description: string;
    category_id: number | null;
    date: string;
    type: 'income' | 'expense';
    recurring_id?: number | null;
  }) => void;
  onCancel: () => void;
}

export function TransactionForm({
  transaction,
  categories,
  type,
  onTypeChange,
  onSubmit,
  onCancel,
}: TransactionFormProps) {
  const { colors } = useTheme();
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');
  const [categoryId, setCategoryId] = useState<number | null>(null);
  const [date, setDate] = useState(getCurrentDate());
  const [showDatePicker, setShowDatePicker] = useState(false);

  const filteredCategories = categories.filter((c) => c.type === type);

  useEffect(() => {
    if (transaction) {
      setAmount(transaction.amount.toString());
      setDescription(transaction.description);
      setCategoryId(transaction.category_id);
      setDate(transaction.date);
    }
  }, [transaction]);

  const handleSubmit = useCallback(() => {
    const parsedAmount = parseFloat(amount.replace(',', '.'));
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      Alert.alert('Errore', 'Inserisci un importo valido maggiore di zero.');
      return;
    }

    onSubmit({
      amount: parsedAmount,
      description: description.trim(),
      category_id: categoryId,
      date,
      type,
    });
  }, [amount, description, categoryId, date, type, onSubmit]);

  const handleDatePickerChange = useCallback((event: DateTimePickerEvent, selectedDate?: Date) => {
    setShowDatePicker(false);
    if (event.type === 'set' && selectedDate) {
      const y = selectedDate.getFullYear();
      const m = String(selectedDate.getMonth() + 1).padStart(2, '0');
      const d = String(selectedDate.getDate()).padStart(2, '0');
      setDate(`${y}-${m}-${d}`);
    }
  }, []);

  const formatDisplayDate = useCallback((dateStr: string) => {
    try {
      const [y, m, d] = dateStr.split('-').map(Number);
      const dt = new Date(y, m - 1, d);
      if (typeof dt.toLocaleDateString === 'function') {
        return dt.toLocaleDateString('it-IT', { day: 'numeric', month: 'long', year: 'numeric' });
      }
      const months = ['gennaio','febbraio','marzo','aprile','maggio','giugno','luglio','agosto','settembre','ottobre','novembre','dicembre'];
      return `${d} ${months[m - 1]} ${y}`;
    } catch {
      return dateStr;
    }
  }, []);

  const handleAmountChange = useCallback((text: string) => {
    const cleaned = text.replace(',', '.');
    if (cleaned === '' || /^\d*\.?\d{0,2}$/.test(cleaned)) {
      setAmount(cleaned);
    }
  }, []);

  return (
    <KeyboardAvoidingView
      style={[styles.container, { backgroundColor: colors.bg }]}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 88 : 0}
    >
      <ScrollView style={styles.scroll} keyboardShouldPersistTaps="handled">
        {/* Type Toggle */}
        <View style={styles.typeToggle}>
          <TouchableOpacity
            style={[
              styles.typeButton,
              type === 'expense' && { backgroundColor: colors.expense },
              type !== 'expense' && { backgroundColor: colors.expenseSoft, borderColor: colors.expense + '30' },
            ]}
            onPress={() => { onTypeChange?.('expense'); setCategoryId(null); }}
          >
            <Text
              style={[
                styles.typeButtonText,
                { color: type === 'expense' ? '#fff' : colors.textSecondary },
              ]}
            >
              Uscita
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[
              styles.typeButton,
              type === 'income' && { backgroundColor: colors.income },
              type !== 'income' && { backgroundColor: colors.incomeSoft, borderColor: colors.income + '30' },
            ]}
            onPress={() => { onTypeChange?.('income'); setCategoryId(null); }}
          >
            <Text
              style={[
                styles.typeButtonText,
                { color: type === 'income' ? '#fff' : colors.textSecondary },
              ]}
            >
              Entrata
            </Text>
          </TouchableOpacity>
        </View>

        {/* Amount Input */}
        <View style={[styles.amountCard, { backgroundColor: colors.glass, borderColor: colors.glassBorder }]}>
          <Text style={[styles.amountLabel, { color: colors.glassTextSecondary }]}>Importo</Text>
          <View style={styles.amountRow}>
            <Text style={[styles.currency, { color: colors.textTertiary }]}>€</Text>
            <TextInput
              style={[styles.amountInput, { color: colors.text }]}
              value={amount}
              onChangeText={handleAmountChange}
              placeholder="0,00"
              placeholderTextColor={colors.textTertiary}
              keyboardType="decimal-pad"
              autoFocus
            />
          </View>
        </View>

        {/* Quick amount buttons */}
        <View style={styles.quickAmounts}>
          {[10, 20, 50, 100, 200].map((val) => (
            <TouchableOpacity
              key={val}
              style={[styles.quickAmountBtn, { backgroundColor: colors.surfaceHover, borderColor: colors.divider }]}
              onPress={() => setAmount(val.toString())}
            >
              <Text style={[styles.quickAmountText, { color: colors.textSecondary }]}>
                €{val}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Description Input */}
        <View style={[styles.inputGroup, { backgroundColor: colors.glass, borderColor: colors.glassBorder }]}>
          <Text style={[styles.label, { color: colors.glassTextSecondary }]}>Descrizione</Text>
          <TextInput
            style={[styles.input, { color: colors.text }]}
            value={description}
            onChangeText={setDescription}
            placeholder="Es. Spesa al supermercato"
            placeholderTextColor={colors.textTertiary}
            maxLength={200}
          />
        </View>

        {/* Date Picker */}
        <View style={[styles.inputGroup, { backgroundColor: colors.glass, borderColor: colors.glassBorder }]}>
          <Text style={[styles.label, { color: colors.glassTextSecondary }]}>Data</Text>
          <TouchableOpacity
            style={[styles.dateButton, { backgroundColor: colors.inputBg }]}
            onPress={() => setShowDatePicker(true)}
            activeOpacity={0.6}
          >
            <Svg width={16} height={16} viewBox="0 0 24 24" fill="none">
              <Rect x="3" y="4" width="18" height="18" rx="2" stroke={colors.textSecondary} strokeWidth={1.5} />
              <Line x1="3" y1="10" x2="21" y2="10" stroke={colors.textSecondary} strokeWidth={1.5} />
              <Line x1="8" y1="2" x2="8" y2="6" stroke={colors.textSecondary} strokeWidth={1.5} strokeLinecap="round" />
              <Line x1="16" y1="2" x2="16" y2="6" stroke={colors.textSecondary} strokeWidth={1.5} strokeLinecap="round" />
            </Svg>
            <Text style={[styles.dateText, { color: colors.text }]}>
              {formatDisplayDate(date)}
            </Text>
            <Svg width={14} height={14} viewBox="0 0 24 24" fill="none">
              <Path d="M6 9l6 6 6-6" stroke={colors.textTertiary} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
            </Svg>
          </TouchableOpacity>
          {showDatePicker && (
            <DateTimePicker
              value={new Date(date + 'T12:00:00')}
              mode="date"
              display={Platform.OS === 'ios' ? 'spinner' : 'default'}
              onChange={handleDatePickerChange}
              maximumDate={new Date()}
              locale="it-IT"
            />
          )}
        </View>

        {/* Category Selection */}
        <View style={[styles.categorySection, { backgroundColor: colors.glass, borderColor: colors.glassBorder }]}>
          <Text style={[styles.label, { color: colors.glassTextSecondary }]}>Categoria</Text>
          <CategoryPicker
            categories={filteredCategories}
            selectedId={categoryId}
            onSelect={(cat) => setCategoryId(cat.id)}
          />
        </View>

        {/* Action Buttons */}
        <View style={styles.actions}>
          <TouchableOpacity
            style={[styles.button, styles.cancelBtn, { backgroundColor: colors.glass, borderColor: colors.glassBorder }]}
            onPress={onCancel}
          >
            <Text style={[styles.cancelText, { color: colors.glassTextSecondary }]}>Annulla</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[
              styles.button,
              styles.submitBtn,
              { backgroundColor: type === 'income' ? colors.income : colors.expense },
            ]}
            onPress={handleSubmit}
          >
            <Text style={styles.submitText}>
              {transaction ? 'Aggiorna' : 'Aggiungi'}
            </Text>
          </TouchableOpacity>
        </View>

        <View style={{ height: 140 }} />
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const FONT_FAMILY = Platform.select({
  ios: '-apple-system',
  android: 'System',
  default: '-apple-system',
}) as string;

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scroll: {
    flex: 1,
    padding: 16,
  },
  typeToggle: {
    flexDirection: 'row',
    marginBottom: 14,
    gap: 8,
    backgroundColor: 'rgba(120,120,128,0.08)',
    borderRadius: 16,
    padding: 3,
  },
  typeButton: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 13,
    alignItems: 'center',
    borderWidth: 0,
  },
  typeButtonText: {
    fontSize: 14,
    fontWeight: '700',
    fontFamily: FONT_FAMILY,
    letterSpacing: -0.1,
  },
  amountCard: {
    padding: 24,
    borderRadius: 22,
    borderWidth: 0.5,
    marginBottom: 14,
    alignItems: 'center',
  },
  amountLabel: {
    fontSize: 12,
    fontWeight: '600',
    marginBottom: 8,
    fontFamily: FONT_FAMILY,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  amountRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  currency: {
    fontSize: 28,
    fontWeight: '300',
    marginRight: 4,
    fontFamily: FONT_FAMILY,
  },
  amountInput: {
    fontSize: 38,
    fontWeight: '800',
    minWidth: 100,
    textAlign: 'center',
    padding: 0,
    fontFamily: FONT_FAMILY,
    letterSpacing: -0.5,
  },
  quickAmounts: {
    flexDirection: 'row',
    gap: 6,
    marginBottom: 16,
  },
  quickAmountBtn: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 14,
    borderWidth: 0.5,
    alignItems: 'center',
  },
  quickAmountText: {
    fontSize: 12,
    fontWeight: '700',
    fontFamily: FONT_FAMILY,
  },
  inputGroup: {
    borderRadius: 18,
    borderWidth: 0.5,
    padding: 16,
    marginBottom: 10,
  },
  dateButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    paddingVertical: 10,
    paddingHorizontal: 14,
    borderRadius: 12,
  },
  dateText: {
    flex: 1,
    fontSize: 15,
    fontWeight: '600',
    fontFamily: FONT_FAMILY,
  },
  label: {
    fontSize: 12,
    fontWeight: '600',
    marginBottom: 8,
    fontFamily: FONT_FAMILY,
    textTransform: 'uppercase',
    letterSpacing: 0.3,
  },
  input: {
    fontSize: 16,
    padding: 0,
    fontFamily: FONT_FAMILY,
  },
  categorySection: {
    borderRadius: 18,
    borderWidth: 0.5,
    padding: 16,
    marginBottom: 14,
  },
  actions: {
    flexDirection: 'row',
    gap: 10,
    marginTop: 6,
  },
  button: {
    flex: 1,
    paddingVertical: 16,
    borderRadius: 18,
    alignItems: 'center',
  },
  cancelBtn: {
    borderWidth: 0.5,
  },
  cancelText: {
    fontSize: 15,
    fontWeight: '700',
    fontFamily: FONT_FAMILY,
  },
  submitBtn: {},
  submitText: {
    fontSize: 15,
    fontWeight: '700',
    color: '#FFFFFF',
    fontFamily: FONT_FAMILY,
  },
});
