import React, { useMemo, useState, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { useTheme } from '../hooks/useTheme';
import { useTransactions } from '../hooks/useTransactions';
import { useCategories } from '../hooks/useCategories';
import { ChartView } from '../components/ChartView';
import { SectionCard } from '../components/SectionCard';
import { formatCurrency } from '../utils/format';
import { useNavigation } from '@react-navigation/native';
import Svg, { Path, Rect, Circle, Line } from 'react-native-svg';
import { GlassView } from '../components/GlassView';

const IT_MONTHS = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];

export function AnnualSummaryScreen() {
  const { colors } = useTheme();
  const navigation = useNavigation<any>();
  const { transactions } = useTransactions();
  const { categories } = useCategories();

  const now = new Date();
  const currentYear = now.getFullYear();
  const [selectedYear, setSelectedYear] = useState(currentYear);

  const availableYears = useMemo(() => {
    const years = new Set<number>();
    transactions.forEach((t) => {
      const y = parseInt(t.date.substring(0, 4));
      if (!isNaN(y)) years.add(y);
    });
    years.add(currentYear);
    return Array.from(years).sort((a, b) => b - a);
  }, [transactions, currentYear]);

  const yearTransactions = useMemo(
    () => transactions.filter((t) => t.date.startsWith(`${selectedYear}-`)),
    [transactions, selectedYear]
  );

  const prevYearTransactions = useMemo(
    () => transactions.filter((t) => t.date.startsWith(`${selectedYear - 1}-`)),
    [transactions, selectedYear]
  );

  const annualTotals = useMemo(() => {
    let income = 0;
    let expense = 0;
    yearTransactions.forEach((t) => {
      if (t.type === 'income') income += t.amount;
      else expense += t.amount;
    });
    return { income, expense, balance: income - expense };
  }, [yearTransactions]);

  const prevAnnualTotals = useMemo(() => {
    let income = 0;
    let expense = 0;
    prevYearTransactions.forEach((t) => {
      if (t.type === 'income') income += t.amount;
      else expense += t.amount;
    });
    return { income, expense, balance: income - expense };
  }, [prevYearTransactions]);

  const monthlyBreakdown = useMemo(() => {
    const months: { income: number; expense: number; balance: number }[] = [];
    for (let m = 0; m < 12; m++) {
      const monthKey = `${selectedYear}-${String(m + 1).padStart(2, '0')}`;
      let income = 0;
      let expense = 0;
      yearTransactions.forEach((t) => {
        if (t.date.startsWith(monthKey)) {
          if (t.type === 'income') income += t.amount;
          else expense += t.amount;
        }
      });
      months.push({ income, expense, balance: income - expense });
    }
    return months;
  }, [yearTransactions, selectedYear]);

  const categoryBreakdown = useMemo(() => {
    const catMap = new Map<number, { income: number; expense: number }>();
    yearTransactions.forEach((t) => {
      const catId = t.category_id ?? 0;
      const entry = catMap.get(catId) || { income: 0, expense: 0 };
      if (t.type === 'income') entry.income += t.amount;
      else entry.expense += t.amount;
      catMap.set(catId, entry);
    });

    const result: { id: number; name: string; color: string; income: number; expense: number; total: number }[] = [];
    catMap.forEach((val, catId) => {
      const cat = categories.find((c) => c.id === catId);
      result.push({
        id: catId,
        name: cat?.name || 'Altro',
        color: cat?.color || '#757575',
        income: Math.round(val.income * 100) / 100,
        expense: Math.round(val.expense * 100) / 100,
        total: Math.round((val.income + val.expense) * 100) / 100,
      });
    });

    return result.sort((a, b) => b.total - a.total);
  }, [yearTransactions, categories]);

  const expensePieData = useMemo(() => {
    return categoryBreakdown
      .filter((c) => c.expense > 0)
      .sort((a, b) => b.expense - a.expense)
      .slice(0, 10)
      .map((c) => ({
        name: c.name,
        amount: c.expense,
        color: c.color,
      }));
  }, [categoryBreakdown]);

  const pctChange = useCallback(
    (current: number, previous: number) => {
      if (previous === 0) return current > 0 ? 100 : 0;
      return Math.round(((current - previous) / Math.abs(previous)) * 100);
    },
    []
  );

  const renderChange = useCallback(
    (current: number, previous: number) => {
      const pct = pctChange(current, previous);
      if (pct === 0) return null;
      const isUp = pct > 0;
      return (
        <Text style={[styles.changeBadge, { color: isUp ? colors.success : colors.expense }]}>
          {isUp ? '↑' : '↓'} {Math.abs(pct)}%
        </Text>
      );
    },
    [pctChange, colors]
  );

  return (
    <View style={[styles.container, { backgroundColor: 'transparent' }]}>
      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()} activeOpacity={0.6} style={styles.backBtn}>
            <Svg width={22} height={22} viewBox="0 0 24 24" fill="none">
              <Path d="M15 18l-6-6 6-6" stroke={colors.text} strokeWidth={2.2} strokeLinecap="round" strokeLinejoin="round" />
            </Svg>
          </TouchableOpacity>
          <Text style={[styles.title, { color: colors.text }]}>Riepilogo Annuale</Text>
          <View style={{ width: 24 }} />
        </View>

        {/* Year Selector */}
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.yearSelector}
        >
          {availableYears.map((y) => (
            <TouchableOpacity
              key={y}
              activeOpacity={0.6}
              style={[
                styles.yearChip,
                {
                  backgroundColor: y === selectedYear ? colors.primary : colors.glass,
                  borderColor: y === selectedYear ? colors.primary : colors.glassBorder,
                },
              ]}
              onPress={() => setSelectedYear(y)}
            >
              <Text
                style={[
                  styles.yearChipText,
                  { color: y === selectedYear ? '#fff' : colors.glassText },
                ]}
              >
                {y}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        {/* Annual Summary Cards */}
        <View style={styles.summaryRow}>
          <GlassView intensity="regular" borderRadius={18} style={styles.summaryCard}>
            <Text style={[styles.summaryLabel, { color: colors.glassTextSecondary }]}>Entrate</Text>
            <Text style={[styles.summaryValue, { color: colors.income }]}>
              {formatCurrency(annualTotals.income)}
            </Text>
            {renderChange(annualTotals.income, prevAnnualTotals.income)}
          </GlassView>
          <GlassView intensity="regular" borderRadius={18} style={styles.summaryCard}>
            <Text style={[styles.summaryLabel, { color: colors.glassTextSecondary }]}>Uscite</Text>
            <Text style={[styles.summaryValue, { color: colors.expense }]}>
              {formatCurrency(annualTotals.expense)}
            </Text>
            {renderChange(annualTotals.expense, prevAnnualTotals.expense)}
          </GlassView>
        </View>

        <GlassView
          intensity="regular"
          borderRadius={18}
          style={styles.balanceCard}
        
        >
          <Text style={[styles.balanceLabel, { color: colors.glassTextSecondary }]}>Saldo {selectedYear}</Text>
          <Text
            style={[
              styles.balanceValue,
              { color: annualTotals.balance >= 0 ? colors.income : colors.expense },
            ]}
          >
            {formatCurrency(annualTotals.balance)}
          </Text>
          {prevAnnualTotals.balance !== 0 && (
            <Text style={[styles.balanceCompare, { color: colors.glassTextTertiary }]}>
              vs {formatCurrency(prevAnnualTotals.balance)} nel {selectedYear - 1}
            </Text>
          )}
        </GlassView>

        {/* Monthly Breakdown Table */}
        <SectionCard title="Dettaglio Mensile">
          <View style={styles.tableHeader}>
            <Text style={[styles.tableHeaderText, { color: colors.glassTextSecondary }]}>Mese</Text>
            <Text style={[styles.tableHeaderText, { color: colors.glassTextSecondary }]}>Entrate</Text>
            <Text style={[styles.tableHeaderText, { color: colors.glassTextSecondary }]}>Uscite</Text>
            <Text style={[styles.tableHeaderText, { color: colors.glassTextSecondary }]}>Saldo</Text>
          </View>
          {monthlyBreakdown.map((m, i) => {
            const hasData = m.income > 0 || m.expense > 0;
            if (!hasData) return null;
            return (
              <View key={i} style={[styles.tableRow, { borderBottomColor: colors.divider }]}>
                <Text style={[styles.tableCell, styles.tableMonth, { color: colors.glassText }]}>
                  {IT_MONTHS[i]}
                </Text>
                <Text style={[styles.tableCell, { color: colors.income }]}>
                  {m.income > 0 ? formatCurrency(m.income) : '—'}
                </Text>
                <Text style={[styles.tableCell, { color: colors.expense }]}>
                  {m.expense > 0 ? formatCurrency(m.expense) : '—'}
                </Text>
                <Text
                  style={[
                    styles.tableCell,
                    styles.tableBalance,
                    { color: m.balance >= 0 ? colors.income : colors.expense },
                  ]}
                >
                  {formatCurrency(m.balance)}
                </Text>
              </View>
            );
          })}
        </SectionCard>

        {/* Expense Pie Chart */}
        {expensePieData.length > 0 && (
          <ChartView type="pie" title="Spese per Categoria" data={expensePieData} totalOverride={annualTotals.expense} />
        )}

        {/* Category Breakdown */}
        {categoryBreakdown.length > 0 && (
          <SectionCard title="Riepilogo Categorie">
            {categoryBreakdown.map((cat) => (
              <View key={cat.id} style={[styles.catRow, { borderBottomColor: colors.divider }]}>
                <View style={styles.catLeft}>
                  <View style={[styles.catDot, { backgroundColor: cat.color }]} />
                  <Text style={[styles.catName, { color: colors.glassText }]}>{cat.name}</Text>
                </View>
                <View style={styles.catRight}>
                  {cat.income > 0 && (
                    <Text style={[styles.catAmount, { color: colors.income }]}>
                      +{formatCurrency(cat.income)}
                    </Text>
                  )}
                  {cat.expense > 0 && (
                    <Text style={[styles.catAmount, { color: colors.expense }]}>
                      −{formatCurrency(cat.expense)}
                    </Text>
                  )}
                </View>
              </View>
            ))}
          </SectionCard>
        )}

        {yearTransactions.length === 0 && (
        <GlassView intensity="regular" borderRadius={18} style={styles.emptyState}>
          <Svg width={36} height={36} viewBox="0 0 24 24" fill="none">
            <Rect x="3" y="14" width="4" height="6" rx="1" stroke={colors.glassTextTertiary} strokeWidth={1.5} strokeLinecap="round" />
            <Rect x="10" y="10" width="4" height="10" rx="1" stroke={colors.glassTextTertiary} strokeWidth={1.5} strokeLinecap="round" />
            <Rect x="17" y="4" width="4" height="16" rx="1" stroke={colors.glassTextTertiary} strokeWidth={1.5} strokeLinecap="round" />
            <Circle cx="5" cy="5" r="2" stroke={colors.glassTextTertiary} strokeWidth={1.2} strokeOpacity={0.4} />
          </Svg>
          <Text style={[styles.emptyText, { color: colors.glassTextSecondary }]}>
            Nessuna transazione per il {selectedYear}
          </Text>
          <Text style={[styles.emptySub, { color: colors.glassTextTertiary }]}>
            Aggiungi transazioni per vedere il riepilogo
          </Text>
        </GlassView>
        )}

        <View style={{ height: 80 }} />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 52,
    paddingBottom: 8,
  },
  backBtn: {
    width: 36,
    height: 36,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontSize: 17,
    fontWeight: '700',
    fontFamily: '-apple-system',
    letterSpacing: -0.2,
  },
  yearSelector: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    gap: 8,
  },
  yearChip: {
    paddingHorizontal: 18,
    paddingVertical: 8,
    borderRadius: 20,
    borderWidth: 0.5,
  },
  yearChipText: {
    fontSize: 14,
    fontWeight: '700',
    fontFamily: '-apple-system',
  },
  summaryRow: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    gap: 10,
    marginBottom: 10,
  },
  summaryCard: {
    flex: 1,
    padding: 16,
  },
  summaryLabel: {
    fontSize: 11,
    fontWeight: '600',
    fontFamily: '-apple-system',
    marginBottom: 4,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  summaryValue: {
    fontSize: 20,
    fontWeight: '800',
    fontFamily: '-apple-system',
    letterSpacing: -0.3,
  },
  changeBadge: {
    fontSize: 11,
    fontWeight: '700',
    fontFamily: '-apple-system',
    marginTop: 4,
  },
  balanceCard: {
    marginHorizontal: 16,
    marginBottom: 12,
    padding: 18,
    alignItems: 'center',
  },
  balanceLabel: {
    fontSize: 11,
    fontWeight: '600',
    fontFamily: '-apple-system',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 4,
  },
  balanceValue: {
    fontSize: 30,
    fontWeight: '800',
    fontFamily: '-apple-system',
    letterSpacing: -0.5,
  },
  balanceCompare: {
    fontSize: 12,
    fontFamily: '-apple-system',
    marginTop: 4,
  },
  tableHeader: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
  tableHeaderText: {
    flex: 1,
    fontSize: 10,
    fontWeight: '700',
    fontFamily: '-apple-system',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    textAlign: 'right',
  },
  tableRow: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderBottomWidth: 0.5,
    alignItems: 'center',
  },
  tableCell: {
    flex: 1,
    fontSize: 13,
    fontWeight: '600',
    fontFamily: '-apple-system',
    textAlign: 'right',
  },
  tableMonth: {
    textAlign: 'left',
    fontWeight: '700',
  },
  tableBalance: {
    fontWeight: '700',
  },
  catRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderBottomWidth: 0.5,
  },
  catLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  catDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 10,
  },
  catName: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: '-apple-system',
  },
  catRight: {
    flexDirection: 'row',
    gap: 10,
  },
  catAmount: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: '-apple-system',
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: 48,
    paddingHorizontal: 40,
    marginTop: 20,
    marginHorizontal: 16,
    gap: 8,
  },
  emptyText: {
    fontSize: 15,
    fontWeight: '600',
    fontFamily: '-apple-system',
    textAlign: 'center',
  },
  emptySub: {
    fontSize: 13,
    fontFamily: '-apple-system',
    textAlign: 'center',
  },
});
