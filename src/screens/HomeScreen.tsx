import React, { useCallback, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  RefreshControl,
} from 'react-native';
import { useTheme } from '../hooks/useTheme';
import { useTransactions } from '../hooks/useTransactions';
import { useCategories } from '../hooks/useCategories';
import { BalanceCard } from '../components/BalanceCard';
import { QuickAddBar } from '../components/QuickAddBar';
import { TransactionItem } from '../components/TransactionItem';
import { Transaction } from '../context/types';
import { useNavigation, useFocusEffect } from '@react-navigation/native';
import { formatCurrency, getCurrentMonth } from '../utils/format';
import Svg, { Path, Circle, Rect, Line } from 'react-native-svg';
import { GlassView } from '../components/GlassView';
import { LogoIcon } from '../components/AppLogo';

function getGreeting(): string {
  const h = new Date().getHours();
  if (h < 12) return 'Buongiorno';
  if (h < 18) return 'Buon pomeriggio';
  return 'Buonasera';
}

export function HomeScreen() {
  const { colors } = useTheme();
  const navigation = useNavigation<any>();
  const { monthlyIncome, monthlyExpense, recentTransactions, transactions } = useTransactions();
  const { categories, getCategoryById } = useCategories();
  const [refreshing, setRefreshing] = React.useState(false);

  useFocusEffect(useCallback(() => {}, []));

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    setRefreshing(false);
  }, []);

  const handlePressTransaction = useCallback(
    (tx: Transaction) => {
      navigation.navigate('AddTransaction', { transactionId: tx.id });
    },
    [navigation]
  );

  // Top expense categories this month
  const topCategories = useMemo(() => {
    const currentMonth = getCurrentMonth();
    const monthExpenses = transactions.filter(
      (t) => t.type === 'expense' && t.date.startsWith(currentMonth)
    );
    const catMap = new Map<number, number>();
    monthExpenses.forEach((t) => {
      const id = t.category_id ?? 0;
      catMap.set(id, (catMap.get(id) || 0) + t.amount);
    });
    const sorted = Array.from(catMap.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3);
    return sorted.map(([id, amount]) => ({
      category: categories.find((c) => c.id === id),
      amount,
    }));
  }, [transactions, categories]);

  // Daily average spending this month
  const dailyAvg = useMemo(() => {
    const currentMonth = getCurrentMonth();
    const now = new Date();
    const dayOfMonth = now.getDate();
    const monthExpenses = transactions
      .filter((t) => t.type === 'expense' && t.date.startsWith(currentMonth))
      .reduce((s, t) => s + t.amount, 0);
    return dayOfMonth > 0 ? monthExpenses / dayOfMonth : 0;
  }, [transactions]);

  const monthlyBalance = monthlyIncome - monthlyExpense;
  const expenseRatio = monthlyIncome > 0 ? (monthlyExpense / monthlyIncome) * 100 : monthlyExpense > 0 ? 100 : 0;

  return (
    <View style={[styles.container, { backgroundColor: 'transparent' }]}>
      <ScrollView
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.primary}
            colors={[colors.primary]}
            progressBackgroundColor={colors.card}
          />
        }
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.headerLeft}>
            <LogoIcon size={36} />
            <View>
              <Text style={[styles.headerLabel, { color: 'rgba(255,255,255,0.75)' }]}>
                {getGreeting()}, Marino
              </Text>
              <Text style={[styles.title, { color: colors.text }]}>Panoramica</Text>
            </View>
          </View>
          <TouchableOpacity
            style={[styles.settingsBtn, { backgroundColor: colors.glass, borderColor: colors.glassBorder }]}
            onPress={() => navigation.getParent()?.navigate('Impostazioni')}
          >
            <Svg width={20} height={20} viewBox="0 0 24 24" fill="none">
              <Circle cx="12" cy="12" r="3" stroke={colors.textSecondary} strokeWidth={1.8} />
              <Path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42" stroke={colors.textSecondary} strokeWidth={1.5} strokeLinecap="round" />
            </Svg>
          </TouchableOpacity>
        </View>

        {/* Balance Card */}
        <BalanceCard income={monthlyIncome} expense={monthlyExpense} />

        {/* Quick Add Bar */}
        <QuickAddBar />

        {/* Insight Cards Row */}
        <View style={styles.insightRow}>
          <GlassView intensity="regular" style={styles.insightCard} borderRadius={18}>
            <View style={[styles.insightIcon, { backgroundColor: colors.primarySoft }]}>
              <Svg width={16} height={16} viewBox="0 0 24 24" fill="none">
                <Path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0a1 1 0 01-1-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 01-1 1" stroke={colors.primary} strokeWidth={1.8} strokeLinecap="round" strokeLinejoin="round" />
              </Svg>
            </View>
            <Text style={[styles.insightLabel, { color: colors.glassTextSecondary }]}>Media giornaliera</Text>
            <Text style={[styles.insightValue, { color: colors.glassText }]}>{formatCurrency(dailyAvg)}</Text>
          </GlassView>

          <GlassView intensity="regular" style={styles.insightCard} borderRadius={18}>
            <View style={[styles.insightIcon, { backgroundColor: expenseRatio > 75 ? colors.expenseSoft : colors.incomeSoft }]}>
              <Svg width={16} height={16} viewBox="0 0 24 24" fill="none">
                <Circle cx="12" cy="12" r="10" stroke={expenseRatio > 75 ? colors.expense : colors.income} strokeWidth={1.8} />
                <Path d="M12 6v6l4 2" stroke={expenseRatio > 75 ? colors.expense : colors.income} strokeWidth={1.8} strokeLinecap="round" />
              </Svg>
            </View>
            <Text style={[styles.insightLabel, { color: colors.glassTextSecondary }]}>Rapporto</Text>
            <Text style={[styles.insightValue, { color: expenseRatio > 75 ? colors.expense : colors.income }]}>
              {Math.round(expenseRatio)}%
            </Text>
          </GlassView>
        </View>

        {/* Top Categories */}
        {topCategories.length > 0 && (
          <View style={styles.sectionHeader}>
            <Text style={[styles.sectionTitle, { color: colors.text }]}>Top Categorie</Text>
            <TouchableOpacity onPress={() => navigation.getParent()?.navigate('Impostazioni', { screen: 'Statistics' })}>
              <Text style={[styles.seeAll, { color: colors.primary }]}>Dettagli</Text>
            </TouchableOpacity>
          </View>
        )}
        {topCategories.map(({ category, amount }, i) => (
          <GlassView
            key={category?.id ?? i}
            intensity="regular"
            style={styles.categoryRow}
            borderRadius={14}
           
          >
            <View style={[styles.catDot, { backgroundColor: category?.color || colors.textTertiary }]} />
            <Text style={[styles.catName, { color: colors.glassText }]} numberOfLines={1}>
              {category?.name || 'Altro'}
            </Text>
            <View style={styles.catBarWrap}>
              <View
                style={[
                  styles.catBar,
                  {
                    backgroundColor: (category?.color || colors.textTertiary) + '25',
                    width: `${Math.min(100, (amount / (topCategories[0]?.amount || 1)) * 100)}%`,
                  },
                ]}
              />
            </View>
            <Text style={[styles.catAmount, { color: colors.glassTextSecondary }]}>
              {formatCurrency(amount)}
            </Text>
          </GlassView>
        ))}

        {/* Recent Transactions */}
        <View style={styles.sectionHeader}>
          <Text style={[styles.sectionTitle, { color: colors.text }]}>Recenti</Text>
          <TouchableOpacity onPress={() => navigation.getParent()?.navigate('Transazioni')}>
            <Text style={[styles.seeAll, { color: colors.primary }]}>Vedi tutte</Text>
          </TouchableOpacity>
        </View>

        {recentTransactions.length === 0 ? (
          <GlassView
            intensity="regular"
            style={styles.emptyContainer}
            borderRadius={18}
           
          >
            <Svg width={36} height={36} viewBox="0 0 24 24" fill="none">
              <Rect x="3" y="4" width="18" height="18" rx="2" stroke={colors.textTertiary} strokeWidth={1.2} />
              <Line x1="3" y1="10" x2="21" y2="10" stroke={colors.textTertiary} strokeWidth={1.2} />
              <Line x1="8" y1="2" x2="8" y2="6" stroke={colors.textTertiary} strokeWidth={1.2} strokeLinecap="round" />
              <Line x1="16" y1="2" x2="16" y2="6" stroke={colors.textTertiary} strokeWidth={1.2} strokeLinecap="round" />
            </Svg>
            <Text style={[styles.emptyText, { color: colors.glassTextSecondary }]}>
              Nessuna transazione ancora
            </Text>
            <Text style={[styles.emptySub, { color: colors.glassTextTertiary }]}>
              Tasto + per aggiungere la prima
            </Text>
          </GlassView>
        ) : (
          <View style={styles.recentListWrap}>
            <GlassView intensity="regular" style={styles.recentGlassWrap} borderRadius={28}>
              {recentTransactions.slice(0, 5).map((tx) => (
                <TransactionItem
                  key={tx.id}
                  transaction={tx}
                  category={getCategoryById(tx.category_id)}
                  onPress={() => handlePressTransaction(tx)}
                  simple
                />
              ))}
            </GlassView>
          </View>
        )}

        <View style={{ height: 100 }} />
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
    paddingHorizontal: 24,
    paddingTop: 54,
    paddingBottom: 4,
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  headerLabel: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: '-apple-system',
    letterSpacing: 0.3,
    marginBottom: 2,
  },
  title: {
    fontSize: 26,
    fontWeight: '700',
    fontFamily: '-apple-system',
    letterSpacing: -0.4,
  },
  settingsBtn: {
    width: 40,
    height: 40,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 0.5,
  },
  insightRow: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    gap: 10,
    marginBottom: 8,
  },
  insightCard: {
    flex: 1,
    padding: 14,
  },
  insightIcon: {
    width: 32,
    height: 32,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 8,
  },
  insightLabel: {
    fontSize: 11,
    fontWeight: '600',
    fontFamily: '-apple-system',
    textTransform: 'uppercase',
    letterSpacing: 0.3,
    marginBottom: 4,
  },
  insightValue: {
    fontSize: 18,
    fontWeight: '800',
    fontFamily: '-apple-system',
    letterSpacing: -0.3,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    marginTop: 20,
    marginBottom: 10,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    fontFamily: '-apple-system',
    letterSpacing: -0.2,
  },
  seeAll: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: '-apple-system',
  },
  categoryRow: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    paddingHorizontal: 16,
    marginHorizontal: 16,
    marginVertical: 3,
    gap: 10,
  },
  catDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
  catName: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: '-apple-system',
    width: 80,
  },
  catBarWrap: {
    flex: 1,
    height: 6,
    borderRadius: 3,
    backgroundColor: 'rgba(120,120,128,0.08)',
    overflow: 'hidden',
  },
  catBar: {
    height: 6,
    borderRadius: 3,
  },
  catAmount: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: '-apple-system',
    minWidth: 60,
    textAlign: 'right',
  },
  emptyContainer: {
    marginHorizontal: 16,
    marginTop: 8,
    padding: 32,
    alignItems: 'center',
    gap: 8,
  },
  recentListWrap: {
    marginHorizontal: 16,
  },
  recentGlassWrap: {
    paddingVertical: 6,
    paddingHorizontal: 8,
  },
  emptyText: {
    fontSize: 15,
    fontWeight: '600',
    fontFamily: '-apple-system',
  },
  emptySub: {
    fontSize: 13,
    fontFamily: '-apple-system',
  },
});
