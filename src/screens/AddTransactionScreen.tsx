import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useTheme } from '../hooks/useTheme';
import { useCategories } from '../hooks/useCategories';
import { useTransactions } from '../hooks/useTransactions';
import { TransactionForm } from '../components/TransactionForm';
import { Transaction } from '../context/types';
import { useNavigation, useRoute } from '@react-navigation/native';
import Svg, { Path } from 'react-native-svg';

export function AddTransactionScreen() {
  const { colors } = useTheme();
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  const { categories } = useCategories();
  const { addTransaction, updateTransaction, transactions } = useTransactions();

  const transactionId = route.params?.transactionId;
  const initialType = route.params?.type || 'expense';

  const [type, setType] = useState<'income' | 'expense'>(initialType);
  const [transaction, setTransaction] = useState<Transaction | null>(null);

  useEffect(() => {
    if (transactionId) {
      const found = transactions.find((t) => t.id === transactionId);
      if (found) {
        setTransaction(found);
        setType(found.type);
      }
    }
  }, [transactionId, transactions]);

  const handleSubmit = async (data: {
    amount: number;
    description: string;
    category_id: number | null;
    date: string;
    type: 'income' | 'expense';
  }) => {
    if (transaction) {
      await updateTransaction({ ...transaction, ...data });
    } else {
      await addTransaction(data as any);
    }
    navigation.goBack();
  };

  const handleCancel = () => {
    navigation.goBack();
  };

  return (
    <View style={[styles.container, { backgroundColor: 'transparent' }]}>
      {/* Header */}
      <View style={[styles.header, { backgroundColor: colors.glass, borderBottomColor: colors.glassBorder }]}>
        <TouchableOpacity onPress={handleCancel} style={styles.closeButton}>
          <Svg width={18} height={18} viewBox="0 0 24 24" fill="none">
            <Path d="M6 6l12 12M18 6L6 18" stroke={colors.text} strokeWidth={2} strokeLinecap="round" />
          </Svg>
        </TouchableOpacity>
        <Text style={[styles.title, { color: colors.text }]}>
          {transaction ? 'Modifica' : 'Nuova Transazione'}
        </Text>
        <View style={{ width: 36 }} />
      </View>

      <TransactionForm
        transaction={transaction}
        categories={categories}
        type={type}
        onTypeChange={setType}
        onSubmit={handleSubmit}
        onCancel={handleCancel}
      />
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
    paddingBottom: 12,
    borderBottomWidth: 0.5,
  },
  closeButton: {
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
});
