import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Transaction, Category } from '../context/types';
import { useTheme } from '../hooks/useTheme';
import { formatCurrency, formatDateShort, FONT_MONO } from '../utils/format';
import { CategoryIcon } from './CategoryIcon';
import { GlassView } from './GlassView';

interface TransactionItemProps {
  transaction: Transaction;
  category?: Category;
  onPress?: () => void;
  onDelete?: () => void;
  simple?: boolean;
}

export function TransactionItem({ transaction, category, onPress, onDelete, simple }: TransactionItemProps) {
  const { colors } = useTheme();
  const isExpense = transaction.type === 'expense';
  const catColor = category?.color || colors.textSecondary;

  const content = (
    <>
      <View style={[styles.iconWrap, { backgroundColor: catColor + '14' }]}>
        <CategoryIcon name={category?.name || ''} icon={category?.icon} size={20} color={catColor} />
      </View>
      <View style={styles.details}>
        <Text style={[styles.desc, { color: colors.glassText }]} numberOfLines={1}>
          {transaction.description || category?.name || 'Senza descrizione'}
        </Text>
        <Text style={[styles.sub, { color: colors.glassTextTertiary }]}>
          {formatDateShort(transaction.date)} · {category?.name || 'Senza categoria'}
        </Text>
      </View>
      <Text style={[styles.amount, { color: isExpense ? colors.expenseLight : colors.incomeLight, fontFamily: FONT_MONO }]}>
        {isExpense ? '−' : '+'}{formatCurrency(transaction.amount)}
      </Text>
    </>
  );

  if (simple) {
    return (
      <TouchableOpacity
        style={styles.simpleContainer}
        activeOpacity={0.6}
        onPress={onPress}
        onLongPress={onDelete}
      >
        {content}
      </TouchableOpacity>
    );
  }

  return (
    <TouchableOpacity
      style={styles.container}
      activeOpacity={0.6}
      onPress={onPress}
      onLongPress={onDelete}
    >
      <GlassView
        intensity="strong"
        style={styles.glassContainer}
        borderRadius={22}
      >
        {content}
      </GlassView>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 14,
    marginHorizontal: 16,
    marginVertical: 3,
  },
  simpleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    paddingHorizontal: 14,
    gap: 12,
  },
  glassContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    paddingHorizontal: 14,
    gap: 12,
  },
  iconWrap: {
    width: 40,
    height: 40,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
  },
  details: { flex: 1, marginRight: 8 },
  desc: { fontSize: 14, fontWeight: '600', fontFamily: '-apple-system', letterSpacing: -0.1 },
  sub: { fontSize: 11, fontWeight: '500', marginTop: 2, fontFamily: '-apple-system' },
  amount: { fontSize: 15, fontWeight: '700', letterSpacing: -0.2 },
});
