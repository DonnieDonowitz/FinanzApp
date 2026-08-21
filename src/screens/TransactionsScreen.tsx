import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useTheme } from '../hooks/useTheme';
import { useTransactions } from '../hooks/useTransactions';
import { useCategories } from '../hooks/useCategories';
import { TransactionList } from '../components/TransactionList';
import { FilterBar } from '../components/FilterBar';
import { Transaction } from '../context/types';
import { useNavigation } from '@react-navigation/native';
import Svg, { Path } from 'react-native-svg';
import { GlassView } from '../components/GlassView';

export function TransactionsScreen() {
  const { colors } = useTheme();
  const navigation = useNavigation<any>();
  const { categories } = useCategories();
  const {
    filteredTransactions,
    filterType,
    setFilterType,
    filterMonth,
    setFilterMonth,
    setFilterCategoryId,
    deleteTransaction,
  } = useTransactions();
  const [showFilters, setShowFilters] = useState(false);

  const handlePressTransaction = useCallback(
    (tx: Transaction) => {
      navigation.navigate('EditTransaction', { transactionId: tx.id });
    },
    [navigation]
  );

  return (
    <View style={[styles.container, { backgroundColor: 'transparent' }]}>
      {/* Header */}
      <View style={styles.header}>
        <View>
          <Text style={[styles.headerLabel, { color: 'rgba(255,255,255,0.75)' }]}>Movimenti recenti</Text>
          <Text style={[styles.title, { color: colors.text }]}>Movimenti</Text>
        </View>
        <GlassView intensity="strong" style={styles.filterToggle} borderRadius={12}>
          <TouchableOpacity
            onPress={() => setShowFilters(!showFilters)}
            style={styles.filterToggleInner}
            activeOpacity={0.6}
          >
            {showFilters ? (
              <Svg width={18} height={18} viewBox="0 0 24 24" fill="none">
                <Path d="M6 6l12 12M18 6L6 18" stroke={colors.primary} strokeWidth={2} strokeLinecap="round" />
              </Svg>
            ) : (
              <Svg width={18} height={18} viewBox="0 0 24 24" fill="none">
                <Path d="M4 4h16l-6 8v6l-4 2v-8L4 4z" stroke={colors.textSecondary} strokeWidth={1.8} strokeLinecap="round" strokeLinejoin="round" />
              </Svg>
            )}
          </TouchableOpacity>
        </GlassView>
      </View>

      {/* Filters */}
      {showFilters && (
        <FilterBar
          filterType={filterType}
          onFilterTypeChange={setFilterType}
          filterMonth={filterMonth}
          onMonthChange={(m) => {
            setFilterMonth(m);
            setFilterCategoryId(null);
          }}
        />
      )}

      {/* Transaction List */}
      <TransactionList
        transactions={filteredTransactions}
        categories={categories}
        onPressItem={handlePressTransaction}
        onDeleteItem={deleteTransaction}
        emptyMessage="Nessuna transazione in questo periodo"
      />

      {/* FAB */}
      <TouchableOpacity
        style={[
          styles.fab,
          {
            backgroundColor: colors.primary,
            shadowColor: colors.primary,
            borderColor: colors.primary + '40',
          },
        ]}
        activeOpacity={0.7}
        onPress={() => navigation.navigate('AddTransaction')}
      >
        <Svg width={24} height={24} viewBox="0 0 24 24" fill="none">
          <Path d="M12 5v14M5 12h14" stroke="#fff" strokeWidth={2.5} strokeLinecap="round" />
        </Svg>
      </TouchableOpacity>
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
    alignItems: 'flex-start',
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
  fab: {
    position: 'absolute',
    right: 20,
    bottom: 24,
    width: 54,
    height: 54,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 6,
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.25,
    shadowRadius: 16,
    borderWidth: 0.5,
  },
  filterToggle: {
    padding: 4,
  },
  filterToggleInner: {
    width: 36,
    height: 36,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
