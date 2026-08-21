import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { RecurringTransaction, Category } from '../context/types';
import { useTheme } from '../hooks/useTheme';
import { formatCurrency, formatDate } from '../utils/format';
import { getFrequencyLabel } from '../utils/scheduling';
import { CategoryIcon } from './CategoryIcon';
import { GlassView } from './GlassView';

interface RecurringItemProps {
  recurring: RecurringTransaction;
  category?: Category;
  onPress?: () => void;
  onDelete?: () => void;
}

export function RecurringItem({ recurring, category, onPress, onDelete }: RecurringItemProps) {
  const { colors } = useTheme();
  const isIncome = recurring.type === 'income';
  const active = recurring.active === 1;

  return (
    <TouchableOpacity
      activeOpacity={0.6}
      onPress={onPress}
      onLongPress={onDelete}
      style={{ opacity: active ? 1 : 0.5 }}
    >
      <GlassView intensity="strong" borderRadius={22} style={styles.container}>
        <View style={[styles.icon, { backgroundColor: (category?.color || colors.primary) + '14' }]}>
          <CategoryIcon name={category?.name || ''} icon={category?.icon} size={22} color={category?.color || colors.primary} />
        </View>
        <View style={styles.details}>
          <Text style={[styles.desc, { color: colors.glassText }]} numberOfLines={1}>
            {recurring.description || category?.name || 'Senza descrizione'}
          </Text>
          <Text style={[styles.sub, { color: colors.glassTextTertiary }]}>
            {getFrequencyLabel(recurring.frequency)} · Prossima: {formatDate(recurring.next_due_date)}
          </Text>
        </View>
        <View style={styles.right}>
          <Text style={[styles.amount, { color: isIncome ? colors.income : colors.glassText }]}>
            {isIncome ? '+' : '−'}{formatCurrency(recurring.amount)}
          </Text>
          <View style={[styles.badge, { backgroundColor: active ? colors.successSoft : colors.inputBg }]}>
            <Text style={[styles.badgeText, { color: active ? colors.success : colors.textTertiary }]}>
              {active ? 'Attiva' : 'Inattiva'}
            </Text>
          </View>
        </View>
      </GlassView>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row', alignItems: 'center', padding: 13, paddingHorizontal: 14,
    marginHorizontal: 16, marginVertical: 3, gap: 12,
  },
  icon: { width: 42, height: 42, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  details: { flex: 1 },
  desc: { fontSize: 14, fontWeight: '600', fontFamily: '-apple-system', letterSpacing: -0.1 },
  sub: { fontSize: 11, fontWeight: '500', marginTop: 2, fontFamily: '-apple-system' },
  right: { alignItems: 'flex-end' },
  amount: { fontSize: 15, fontWeight: '700', fontFamily: '-apple-system', marginBottom: 2, letterSpacing: -0.2 },
  badge: { paddingHorizontal: 8, paddingVertical: 2, borderRadius: 6 },
  badgeText: { fontSize: 10, fontWeight: '700', fontFamily: '-apple-system' },
});
