import React, { useCallback, useState } from 'react';
import { FlatList, StyleSheet, View, Text } from 'react-native';
import { Transaction, Category } from '../context/types';
import { TransactionItem } from './TransactionItem';
import { useTheme } from '../hooks/useTheme';
import { ConfirmDialog } from './ConfirmDialog';
import { GlassView } from './GlassView';
import Svg, { Path, Line } from 'react-native-svg';

interface TransactionListProps {
  transactions: Transaction[];
  categories: Category[];
  onPressItem?: (transaction: Transaction) => void;
  onDeleteItem?: (id: number) => void;
  emptyMessage?: string;
}

export function TransactionList({
  transactions, categories, onPressItem, onDeleteItem,
  emptyMessage = 'Nessuna transazione',
}: TransactionListProps) {
  const { colors } = useTheme();
  const [deleteId, setDeleteId] = useState<number | null>(null);

  const getCategory = useCallback(
    (id: number | null) => id === null ? undefined : categories.find((c) => c.id === id),
    [categories],
  );

  const confirmDelete = useCallback(() => {
    if (deleteId !== null && onDeleteItem) onDeleteItem(deleteId);
    setDeleteId(null);
  }, [deleteId, onDeleteItem]);

  const renderItem = useCallback(
    ({ item }: { item: Transaction }) => (
      <TransactionItem
        transaction={item}
        category={getCategory(item.category_id)}
        onPress={onPressItem ? () => onPressItem(item) : undefined}
        onDelete={onDeleteItem ? () => setDeleteId(item.id) : undefined}
      />
    ),
    [getCategory, onPressItem, onDeleteItem],
  );

  return (
    <>
      <FlatList
        data={transactions}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderItem}
        contentContainerStyle={[
          styles.list,
          transactions.length === 0 && styles.emptyList,
        ]}
        ListEmptyComponent={
          <GlassView intensity="regular" borderRadius={18} style={styles.emptyWrap}>
            <Svg width={32} height={32} viewBox="0 0 24 24" fill="none">
              <Path d="M3 12h4l3 9h4l3-9h4" stroke={colors.glassTextTertiary} strokeWidth={1.6} strokeLinecap="round" strokeLinejoin="round" />
              <Path d="M21 12V5a2 2 0 00-2-2H5a2 2 0 00-2 2v7" stroke={colors.glassTextTertiary} strokeWidth={1.6} strokeLinecap="round" strokeLinejoin="round" />
              <Line x1="8" y1="11" x2="16" y2="14" stroke={colors.glassTextTertiary} strokeWidth={1.2} strokeLinecap="round" strokeOpacity={0.4} />
            </Svg>
            <Text style={[styles.emptyText, { color: colors.glassTextSecondary }]}>{emptyMessage}</Text>
          </GlassView>
        }
      />
      <ConfirmDialog
        visible={deleteId !== null}
        title="Elimina transazione"
        message="Sei sicuro di voler eliminare questa transazione?"
        confirmText="Elimina"
        cancelText="Annulla"
        onConfirm={confirmDelete}
        onCancel={() => setDeleteId(null)}
        danger
      />
    </>
  );
}

const styles = StyleSheet.create({
  list: { paddingVertical: 8, paddingBottom: 80 },
  emptyList: { flexGrow: 1 },
  emptyWrap: { margin: 16, paddingVertical: 48, alignItems: 'center' },
  emptyText: { fontSize: 14, fontWeight: '600', marginTop: 12, fontFamily: '-apple-system' },
});
