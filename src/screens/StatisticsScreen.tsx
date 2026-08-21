import React, { useMemo, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Modal } from 'react-native';
import { useTheme } from '../hooks/useTheme';
import { useTransactions } from '../hooks/useTransactions';
import { useCategories } from '../hooks/useCategories';
import { ChartView } from '../components/ChartView';
import { formatCurrency, formatDateShort, getCurrentMonth, FONT_MONO } from '../utils/format';
import { useNavigation } from '@react-navigation/native';
import Svg, { Path, Circle, Rect, Line } from 'react-native-svg';
import { GlassView } from '../components/GlassView';

function truncateName(name: string): string {
  return name.length > 25 ? name.slice(0, 22) + '...' : name;
}

const IT_MONTHS = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];

type Period = 'month' | 'quarter' | 'year';

export function StatisticsScreen() {
  const { colors } = useTheme();
  const navigation = useNavigation<any>();
  const { transactions } = useTransactions();
  const { categories } = useCategories();

  const currentMonth = getCurrentMonth();
  const [period, setPeriod] = useState<Period>('month');
  const [selectedCategory, setSelectedCategory] = useState<{ id: number; name: string; color: string } | null>(null);

  function lastDayOfMonth(year: number, month: number): number {
    return new Date(year, month + 1, 0).getDate();
  }

  // Compute date range based on selected period
  const dateRange = useMemo(() => {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth(); // 0-based

    if (period === 'month') {
      const key = `${year}-${String(month + 1).padStart(2, '0')}`;
      const lastDay = lastDayOfMonth(year, month);
      return { start: `${key}-01`, end: `${key}-${String(lastDay).padStart(2, '0')}`, label: IT_MONTHS[month] };
    }
    if (period === 'quarter') {
      const qStart = Math.floor(month / 3) * 3;
      const qEnd = qStart + 2;
      const lastDay = lastDayOfMonth(year, qEnd);
      return {
        start: `${year}-${String(qStart + 1).padStart(2, '0')}-01`,
        end: `${year}-${String(qEnd + 1).padStart(2, '0')}-${String(lastDay).padStart(2, '0')}`,
        label: `Q${Math.floor(month / 3) + 1}`,
      };
    }
    return {
      start: `${year}-01-01`,
      end: `${year}-12-31`,
      label: `${year}`,
    };
  }, [period]);

  // Filtered transactions for the selected period
  const periodTransactions = useMemo(
    () => transactions.filter((t) => t.date >= dateRange.start && t.date <= dateRange.end),
    [transactions, dateRange]
  );

  // Period totals
  const periodTotals = useMemo(() => {
    let income = 0;
    let expense = 0;
    periodTransactions.forEach((t) => {
      if (t.type === 'income') income += t.amount;
      else expense += t.amount;
    });
    return { income, expense, balance: income - expense };
  }, [periodTransactions]);

  // Previous period computation for trend
  const prevDateRange = useMemo(() => {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth();

    if (period === 'month') {
      const prevMonth = month === 0 ? 11 : month - 1;
      const prevYear = month === 0 ? year - 1 : year;
      const lastDay = lastDayOfMonth(prevYear, prevMonth);
      return {
        start: `${prevYear}-${String(prevMonth + 1).padStart(2, '0')}-01`,
        end: `${prevYear}-${String(prevMonth + 1).padStart(2, '0')}-${String(lastDay).padStart(2, '0')}`,
      };
    }
    if (period === 'quarter') {
      const qStart = Math.floor(month / 3) * 3;
      const prevQStart = qStart - 3;
      const prevYear = prevQStart < 0 ? year - 1 : year;
      const adjQStart = prevQStart < 0 ? prevQStart + 12 : prevQStart;
      const qEnd = adjQStart + 2;
      const lastDay = lastDayOfMonth(prevYear, qEnd);
      return {
        start: `${prevYear}-${String(adjQStart + 1).padStart(2, '0')}-01`,
        end: `${prevYear}-${String(qEnd + 1).padStart(2, '0')}-${String(lastDay).padStart(2, '0')}`,
      };
    }
    return {
      start: `${year - 1}-01-01`,
      end: `${year - 1}-12-31`,
    };
  }, [period]);

  const prevPeriodTransactions = useMemo(
    () => transactions.filter((t) => t.date >= prevDateRange.start && t.date <= prevDateRange.end),
    [transactions, prevDateRange]
  );

  const prevPeriodBalance = useMemo(
    () => prevPeriodTransactions.reduce((s, t) => s + (t.type === 'income' ? t.amount : -t.amount), 0),
    [prevPeriodTransactions]
  );

  const periodDiff = useMemo(() => {
    if (prevPeriodBalance === 0) return periodTotals.balance > 0 ? 100 : periodTotals.balance < 0 ? -100 : 0;
    return ((periodTotals.balance - prevPeriodBalance) / Math.abs(prevPeriodBalance)) * 100;
  }, [periodTotals.balance, prevPeriodBalance]);

  // Pie chart data: expense by category for selected period
  const expenseByCategory = useMemo(() => {
    const catMap = new Map<number, number>();
    periodTransactions
      .filter((t) => t.type === 'expense')
      .forEach((t) => {
        const catId = t.category_id ?? 0;
        catMap.set(catId, (catMap.get(catId) || 0) + t.amount);
      });

    const pieData: any[] = [];
    catMap.forEach((amount, catId) => {
      const cat = categories.find((c) => c.id === catId);
      pieData.push({
        name: cat?.name || 'Altro',
        amount: Math.round(amount * 100) / 100,
        color: cat?.color || '#757575',
      });
    });

    return pieData
      .filter((d) => d.amount > 0)
      .sort((a, b) => b.amount - a.amount)
      .slice(0, 10);
  }, [periodTransactions, categories]);

  // Stacked bar chart: monthly income and expense, filtered to the selected period
  const barData = useMemo(() => {
    const year = currentMonth.substring(0, 4);
    const monthData: { income: number; expense: number; label: string }[] = [];
    const [startYear, startMonth] = dateRange.start.split('-').map(Number);
    const [endYear, endMonth] = dateRange.end.split('-').map(Number);

    for (let m = startMonth - 1; m <= endMonth - 1; m++) {
      const monthKey = `${year}-${String(m + 1).padStart(2, '0')}`;
      const income = transactions
        .filter((t) => t.type === 'income' && t.date.startsWith(monthKey))
        .reduce((s, t) => s + t.amount, 0);
      const expense = transactions
        .filter((t) => t.type === 'expense' && t.date.startsWith(monthKey))
        .reduce((s, t) => s + t.amount, 0);
      monthData.push({ income, expense, label: IT_MONTHS[m] });
    }

    return monthData;
  }, [transactions, currentMonth, dateRange]);

  const maxMonthTotal = useMemo(
    () => Math.max(1, ...barData.map((m) => m.income + m.expense)),
    [barData]
  );

  const periodExpenseTotal = useMemo(
    () => periodTransactions.filter((t) => t.type === 'expense').reduce((s, t) => s + t.amount, 0),
    [periodTransactions]
  );

  // Top expense categories list
  const topExpenseCategories = useMemo(() => {
    const catMap = new Map<number, { income: number; expense: number }>();
    periodTransactions.forEach((t) => {
      const id = t.category_id ?? 0;
      const entry = catMap.get(id) || { income: 0, expense: 0 };
      if (t.type === 'income') entry.income += t.amount;
      else entry.expense += t.amount;
      catMap.set(id, entry);
    });
    const result: { id: number; name: string; color: string; income: number; expense: number }[] = [];
    catMap.forEach((val, id) => {
      const cat = categories.find((c) => c.id === id);
      result.push({
        id,
        name: cat?.name || 'Altro',
        color: cat?.color || '#757575',
        income: val.income,
        expense: val.expense,
      });
    });
    return result.sort((a, b) => b.expense - a.expense).slice(0, 8);
  }, [periodTransactions, categories]);

  const periodOptions: { key: Period; label: string }[] = [
    { key: 'month', label: 'Mese' },
    { key: 'quarter', label: 'Trimestre' },
    { key: 'year', label: 'Anno' },
  ];

  return (
    <View style={[styles.container, { backgroundColor: 'transparent' }]}>
      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <View>
            <Text style={[styles.headerLabel, { color: 'rgba(255,255,255,0.75)' }]}>Analisi mensile</Text>
            <Text style={[styles.title, { color: colors.text }]}>Statistiche</Text>
          </View>
        </View>

        {/* Period Selector */}
        <GlassView intensity="strong" style={styles.periodSelector} borderRadius={20}>
          {periodOptions.map((opt) => (
            <TouchableOpacity
              key={opt.key}
              style={[
                styles.periodBtn,
                period === opt.key && { backgroundColor: 'rgba(255,255,255,0.9)' },
              ]}
              onPress={() => setPeriod(opt.key)}
            >
              <Text
                style={[
                  styles.periodBtnText,
                  { color: period === opt.key ? colors.inputBg : colors.glassTextSecondary },
                ]}
              >
                {opt.label}
              </Text>
            </TouchableOpacity>
          ))}
        </GlassView>

        {/* Period Summary Cards */}
        <View style={styles.summaryRow}>
          <GlassView intensity="regular" style={styles.summaryCard} borderRadius={18}>
            <Text style={[styles.summaryLabel, { color: colors.glassTextSecondary }]}>Entrate</Text>
            <Text style={[styles.summaryValue, { color: colors.income }]}>
              {formatCurrency(periodTotals.income)}
            </Text>
          </GlassView>
          <GlassView intensity="regular" style={styles.summaryCard} borderRadius={18}>
            <Text style={[styles.summaryLabel, { color: colors.glassTextSecondary }]}>Uscite</Text>
            <Text style={[styles.summaryValue, { color: colors.expense }]}>
              {formatCurrency(periodTotals.expense)}
            </Text>
          </GlassView>
        </View>

        {/* Percent difference vs last period */}
        <GlassView intensity="regular" borderRadius={18} style={styles.diffCard}>
          <Text style={[styles.balanceLabel, { color: colors.glassTextSecondary }]}>
            Trend vs periodo prec.
          </Text>
          <Text style={[styles.diffValue, { color: periodDiff >= 0 ? colors.income : colors.expense }]}>
            {periodDiff >= 0 ? '+' : ''}{periodDiff.toFixed(1)}%
          </Text>
        </GlassView>

        {/* Annual Summary Button */}
        <GlassView intensity="regular" borderRadius={18} style={styles.annualBtn}>
          <TouchableOpacity
            activeOpacity={0.6}
            onPress={() => navigation.navigate('AnnualSummary')}
          >
            <View style={styles.annualBtnContent}>
              <View style={[styles.annualBtnIconWrap, { backgroundColor: colors.primarySoft }]}>
                <Svg width={20} height={20} viewBox="0 0 24 24" fill="none">
                  <Rect x="3" y="4" width="18" height="16" rx="2" stroke={colors.primary} strokeWidth={1.6} />
                  <Line x1="3" y1="10" x2="21" y2="10" stroke={colors.primary} strokeWidth={1.6} />
                  <Line x1="8" y1="2" x2="8" y2="6" stroke={colors.primary} strokeWidth={1.6} strokeLinecap="round" />
                  <Line x1="16" y1="2" x2="16" y2="6" stroke={colors.primary} strokeWidth={1.6} strokeLinecap="round" />
                </Svg>
              </View>
              <View style={styles.annualBtnText}>
                <Text style={[styles.annualBtnTitle, { color: colors.glassText }]}>Riepilogo Annuale</Text>
                <Text style={[styles.annualBtnSub, { color: colors.glassTextSecondary }]}>
                  Analisi dettagliata per anno
                </Text>
              </View>
              <Svg width={16} height={16} viewBox="0 0 24 24" fill="none">
                <Path d="M9 6l6 6-6 6" stroke={colors.glassTextTertiary} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
              </Svg>
            </View>
          </TouchableOpacity>
        </GlassView>

        {/* Expense Pie Chart */}
        <ChartView
          type="pie"
          title={`Spese per Categoria — ${dateRange.label}`}
          data={expenseByCategory}
          totalOverride={periodTotals.expense}
        />

        {/* Monthly Balance Bar Chart — stacked income/expense */}
        <GlassView intensity="regular" style={styles.chartCard} borderRadius={22}>
          <Text style={[styles.chartCardLabel, { color: 'rgba(255,255,255,0.7)' }]}>
            RISPARMIO NETTO · {dateRange.label.toUpperCase()}
          </Text>
          <Text style={[styles.chartCardBigNum, { color: colors.glassText, fontFamily: FONT_MONO }]}>
            {formatCurrency(periodTotals.balance)}
          </Text>

          <View style={styles.barsContainer}>
            {barData.map((m, i) => {
              const total = m.income + m.expense;
              const incomePct = maxMonthTotal > 0 ? (m.income / maxMonthTotal) * 100 : 0;
              const expensePct = maxMonthTotal > 0 ? (m.expense / maxMonthTotal) * 100 : 0;
              const hasData = total > 0;
              return (
                <View key={i} style={styles.barCol}>
                  <View style={styles.barStack}>
                    {hasData && <View style={[styles.bar, styles.barIncome, { height: `${Math.max(incomePct, 2)}%` }]} />}
                    {hasData && <View style={[styles.bar, styles.barExpense, { height: `${Math.max(expensePct, 2)}%` }]} />}
                    {!hasData && <View style={{ flex: 1 }} />}
                  </View>
                  <Text style={[styles.barLabel, { color: 'rgba(255,255,255,0.6)' }]}>{m.label}</Text>
                </View>
              );
            })}
          </View>

          <View style={styles.legendRow}>
            <View style={styles.legendItem}>
              <View style={[styles.legendSwatch, { backgroundColor: '#1FD8A4' }]} />
              <Text style={[styles.legendText, { color: 'rgba(255,255,255,0.75)' }]}>Entrate</Text>
            </View>
            <View style={styles.legendItem}>
              <View style={[styles.legendSwatch, { backgroundColor: '#FF6B6B' }]} />
              <Text style={[styles.legendText, { color: 'rgba(255,255,255,0.75)' }]}>Uscite</Text>
            </View>
          </View>
        </GlassView>

        {/* Section header: Uscite per categoria / month */}
        <View style={styles.sectionHeaderRow}>
          <Text style={[styles.sectionHeaderTitle, { color: colors.text }]}>Uscite per categoria</Text>
          <Text style={[styles.sectionHeaderLink, { color: 'rgba(255,255,255,0.7)' }]}>{dateRange.label}</Text>
        </View>

        {/* Category List */}
        {topExpenseCategories.length > 0 && (
          <GlassView intensity="regular" style={styles.catGlassWrap} borderRadius={28}>
            {topExpenseCategories.map((cat) => {
              const pct = periodExpenseTotal > 0 ? (cat.expense / periodExpenseTotal) * 100 : 0;
              return (
                <TouchableOpacity
                  key={cat.id}
                  activeOpacity={0.6}
                  onPress={() => setSelectedCategory({ id: cat.id, name: cat.name, color: cat.color })}
                  style={styles.catRow}
                >
                  <View style={[styles.catIconWrap, { backgroundColor: cat.color + '28' }]}>
                    <View style={[styles.catIconDot, { backgroundColor: cat.color }]} />
                  </View>
                  <View style={styles.catInfo}>
                    <View style={styles.catInfoTop}>
                      <Text style={[styles.catName, { color: colors.glassText }]}>{truncateName(cat.name)}</Text>
                      <Text style={[styles.catPct, { color: 'rgba(255,255,255,0.7)', fontFamily: FONT_MONO }]}>
                        {formatCurrency(cat.expense)} · {Math.round(pct)}%
                      </Text>
                    </View>
                    <View style={styles.catBarTrack}>
                      <View style={[styles.catBarFill, { width: `${Math.min(pct, 100)}%`, backgroundColor: cat.color }]} />
                    </View>
                  </View>
                </TouchableOpacity>
              );
            })}
          </GlassView>
        )}

        {periodTransactions.length === 0 && (
          <GlassView
            intensity="regular"
            style={styles.emptyState}
            borderRadius={18}
           
          >
            <Svg width={36} height={36} viewBox="0 0 24 24" fill="none">
              <Circle cx="12" cy="12" r="9" stroke={colors.textTertiary} strokeWidth={1.2} />
              <Path d="M12 7v5l3 3" stroke={colors.textTertiary} strokeWidth={1.2} strokeLinecap="round" />
            </Svg>
            <Text style={[styles.emptyText, { color: colors.glassTextSecondary }]}>
              Nessuna transazione in questo periodo
            </Text>
          </GlassView>
        )}

        <View style={{ height: 100 }} />
      </ScrollView>

      {/* Category Transactions Modal */}
      <Modal visible={selectedCategory !== null} transparent animationType="slide" onRequestClose={() => setSelectedCategory(null)}>
        <View style={[styles.modalOverlay, { backgroundColor: colors.overlay }]}>
          <GlassView intensity="strong" borderRadius={22} noHighlight style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <View style={styles.modalHeaderLeft}>
                <View style={[styles.modalDot, { backgroundColor: selectedCategory?.color }]} />
                <Text style={[styles.modalTitle, { color: colors.glassText }]} numberOfLines={1}>
                  {selectedCategory?.name ? truncateName(selectedCategory.name) : ''}
                </Text>
              </View>
              <TouchableOpacity onPress={() => setSelectedCategory(null)} style={[styles.modalClose, { backgroundColor: colors.inputBg }]}>
                <Text style={[styles.modalCloseText, { color: colors.glassTextSecondary }]}>Chiudi</Text>
              </TouchableOpacity>
            </View>
            <ScrollView style={styles.modalScroll} showsVerticalScrollIndicator={false}>
              {selectedCategory && periodTransactions
                .filter((t) => t.type === 'expense' && (t.category_id ?? 0) === selectedCategory.id)
                .sort((a, b) => b.date.localeCompare(a.date))
                .map((tx) => (
                  <View key={tx.id} style={[styles.modalTxRow, { borderBottomColor: colors.divider }]}>
                    <View style={styles.modalTxLeft}>
                      <Text style={[styles.modalTxDesc, { color: colors.glassText }]} numberOfLines={1}>
                        {tx.description || 'Senza descrizione'}
                      </Text>
                      <Text style={[styles.modalTxDate, { color: colors.glassTextTertiary }]}>
                        {formatDateShort(tx.date)}
                      </Text>
                    </View>
                    <Text style={[styles.modalTxAmount, { color: colors.expenseLight, fontFamily: FONT_MONO }]}>
                      −{formatCurrency(tx.amount)}
                    </Text>
                  </View>
                ))}
              {selectedCategory && periodTransactions.filter((t) => t.type === 'expense' && (t.category_id ?? 0) === selectedCategory.id).length === 0 && (
                <Text style={[styles.modalEmpty, { color: colors.glassTextTertiary }]}>Nessuna transazione</Text>
              )}
            </ScrollView>
          </GlassView>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 24,
    paddingTop: 54,
    paddingBottom: 4,
  },
  title: {
    fontFamily: '-apple-system',
    fontSize: 26,
    fontWeight: '700',
    letterSpacing: -0.4,
  },
  headerLabel: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: '-apple-system',
    letterSpacing: 0.3,
    marginBottom: 2,
  },
  periodSelector: {
    flexDirection: 'row',
    marginHorizontal: 16,
    marginBottom: 12,
    borderRadius: 20,
    padding: 4,
    gap: 4,
  },
  periodBtn: {
    flex: 1,
    paddingVertical: 8,
    borderRadius: 16,
    alignItems: 'center',
  },
  periodBtnText: {
    fontSize: 12.5,
    fontWeight: '700',
    fontFamily: '-apple-system',
    letterSpacing: -0.1,
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
  diffCard: {
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
  diffValue: {
    fontSize: 28,
    fontWeight: '800',
    fontFamily: '-apple-system',
    letterSpacing: -0.5,
  },
  annualBtn: {
    marginHorizontal: 16,
    marginBottom: 12,
  },
  annualBtnIconWrap: {
    width: 40,
    height: 40,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  annualBtnContent: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    gap: 12,
  },
  annualBtnText: {
    flex: 1,
  },
  annualBtnTitle: {
    fontSize: 14,
    fontWeight: '700',
    fontFamily: '-apple-system',
    letterSpacing: -0.1,
  },
  annualBtnSub: {
    fontSize: 12,
    fontFamily: '-apple-system',
    marginTop: 2,
  },
  chartCard: {
    marginHorizontal: 16,
    marginBottom: 12,
    padding: 20,
    paddingBottom: 14,
  },
  chartCardLabel: {
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 0.3,
    fontFamily: '-apple-system',
  },
  chartCardBigNum: {
    fontSize: 30,
    fontWeight: '700',
    letterSpacing: -0.5,
    marginTop: 6,
  },
  barsContainer: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    gap: 10,
    height: 120,
    marginTop: 18,
  },
  barCol: {
    flex: 1,
    alignItems: 'center',
    gap: 8,
  },
  barStack: {
    width: '100%',
    height: 96,
    justifyContent: 'flex-end',
    gap: 3,
  },
  bar: {
    width: '100%',
    borderRadius: 6,
  },
  barIncome: {
    backgroundColor: '#1FD8A4',
  },
  barExpense: {
    backgroundColor: '#FF6B6B',
  },
  barLabel: {
    fontSize: 10.5,
    fontWeight: '700',
    fontFamily: '-apple-system',
  },
  legendRow: {
    flexDirection: 'row',
    gap: 16,
    marginTop: 14,
  },
  legendItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  legendSwatch: {
    width: 9,
    height: 9,
    borderRadius: 3,
  },
  legendText: {
    fontSize: 11.5,
    fontWeight: '600',
    fontFamily: '-apple-system',
  },
  sectionHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'baseline',
    marginHorizontal: 20,
    marginTop: 20,
    marginBottom: 10,
  },
  sectionHeaderTitle: {
    fontSize: 17,
    fontWeight: '700',
    fontFamily: '-apple-system',
    letterSpacing: -0.2,
  },
  sectionHeaderLink: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: '-apple-system',
  },
  catGlassWrap: {
    marginHorizontal: 16,
    paddingVertical: 6,
    paddingHorizontal: 8,
  },
  catRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingVertical: 10,
    paddingHorizontal: 6,
  },
  catIconWrap: {
    width: 38,
    height: 38,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  catIconDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  catInfo: {
    flex: 1,
  },
  catInfoTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  catName: {
    fontSize: 13.5,
    fontWeight: '600',
    fontFamily: '-apple-system',
  },
  catPct: {
    fontSize: 12,
    fontWeight: '600',
  },
  catBarTrack: {
    height: 6,
    borderRadius: 4,
    backgroundColor: 'rgba(255,255,255,0.18)',
    marginTop: 7,
    overflow: 'hidden',
  },
  catBarFill: {
    height: '100%',
    borderRadius: 4,
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: 48,
    marginHorizontal: 16,
    borderRadius: 18,
    borderWidth: 0.5,
    gap: 8,
  },
  emptyText: {
    fontSize: 14,
    fontWeight: '600',
    fontFamily: '-apple-system',
  },
  modalOverlay: {
    flex: 1,
    justifyContent: 'flex-end',
  },
  modalContent: {
    maxHeight: '70%',
    borderTopLeftRadius: 22,
    borderTopRightRadius: 22,
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    paddingBottom: 12,
  },
  modalHeaderLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    flex: 1,
  },
  modalDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  modalTitle: {
    fontSize: 16,
    fontWeight: '700',
    fontFamily: '-apple-system',
    letterSpacing: -0.2,
    flex: 1,
  },
  modalClose: {
    paddingHorizontal: 14,
    paddingVertical: 7,
    borderRadius: 12,
  },
  modalCloseText: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: '-apple-system',
  },
  modalScroll: {
    paddingHorizontal: 20,
    paddingBottom: 20,
  },
  modalTxRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 0.5,
  },
  modalTxLeft: {
    flex: 1,
    marginRight: 12,
  },
  modalTxDesc: {
    fontSize: 14,
    fontWeight: '600',
    fontFamily: '-apple-system',
  },
  modalTxDate: {
    fontSize: 12,
    fontFamily: '-apple-system',
    marginTop: 2,
  },
  modalTxAmount: {
    fontSize: 14,
    fontWeight: '700',
  },
  modalEmpty: {
    textAlign: 'center',
    paddingVertical: 32,
    fontSize: 14,
    fontFamily: '-apple-system',
  },
});
