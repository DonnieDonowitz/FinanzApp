import React, { useState, useCallback, useMemo } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useTheme } from '../hooks/useTheme';
import { useRecurring } from '../hooks/useRecurring';
import { useCategories } from '../hooks/useCategories';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { EmptyState } from '../components/EmptyState';
import { RecurringTransaction } from '../context/types';
import { useNavigation } from '@react-navigation/native';
import { GlassView } from '../components/GlassView';
import { formatCurrency, formatDate, FONT_MONO } from '../utils/format';
import { getFrequencyLabel } from '../utils/scheduling';
import { CategoryIcon } from '../components/CategoryIcon';

export function RecurringScreen() {
  const { colors } = useTheme();
  const navigation = useNavigation<any>();
  const { recurring, deleteRecurring, updateRecurring } = useRecurring();
  const { categories } = useCategories();
  const [deleteId, setDeleteId] = useState<number | null>(null);

  const handlePress = useCallback(
    (rec: RecurringTransaction) => { navigation.navigate('EditRecurring', { recurringId: rec.id }); },
    [navigation]
  );

  const handleDelete = useCallback(async () => {
    if (deleteId !== null) { await deleteRecurring(deleteId); setDeleteId(null); }
  }, [deleteId, deleteRecurring]);

  const handleToggle = useCallback(async (rec: RecurringTransaction) => {
    await updateRecurring({ ...rec, active: rec.active === 1 ? 0 : 1 });
  }, [updateRecurring]);

  const activeRecurring = useMemo(() => recurring.filter((r) => r.active === 1), [recurring]);
  const monthlyTotal = useMemo(() => {
    const monthly = activeRecurring.reduce((s, r) => {
      if (r.frequency === 'daily') return s + r.amount * 30;
      if (r.frequency === 'weekly') return s + r.amount * 4.33;
      if (r.frequency === 'monthly') return s + r.amount;
      if (r.frequency === 'yearly') return s + r.amount / 12;
      return s;
    }, 0);
    return monthly;
  }, [activeRecurring]);

  const nextDue = useMemo(() => {
    const upcoming = [...recurring]
      .filter((r) => r.active === 1)
      .sort((a, b) => a.next_due_date.localeCompare(b.next_due_date));
    return upcoming[0] ?? null;
  }, [recurring]);

  const daysUntilNext = useMemo(() => {
    if (!nextDue) return null;
    const today = new Date();
    const next = new Date(nextDue.next_due_date);
    const diff = Math.ceil((next.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
    return diff;
  }, [nextDue]);

  return (
    <View style={[styles.container, { backgroundColor: 'transparent' }]}>
      <View style={styles.header}>
        <View>
          <Text style={[styles.headerLabel, { color: 'rgba(255,255,255,0.75)' }]}>Abbonamenti e pagamenti fissi</Text>
          <Text style={[styles.title, { color: colors.text }]}>Ricorrenti</Text>
        </View>
      </View>

      {recurring.length > 0 && (
        <GlassView intensity="regular" style={styles.summary} borderRadius={16}>
          <View style={styles.summaryRow}>
            <View style={styles.summaryItem}>
              <Text style={[styles.summaryLabel, { color: colors.glassTextSecondary }]}>Totale / Mese</Text>
              <Text style={[styles.summaryValue, { color: colors.glassText, fontFamily: FONT_MONO }]}>{formatCurrency(monthlyTotal)}</Text>
            </View>
            <View style={[styles.summaryDivider, { backgroundColor: colors.divider }]} />
            <View style={styles.summaryItem}>
              <Text style={[styles.summaryLabel, { color: colors.glassTextSecondary }]}>Attive</Text>
              <Text style={[styles.summaryValue, { color: colors.success }]}>{activeRecurring.length}</Text>
            </View>
            <View style={[styles.summaryDivider, { backgroundColor: colors.divider }]} />
            <View style={styles.summaryItem}>
              <Text style={[styles.summaryLabel, { color: colors.glassTextSecondary }]}>Prossima</Text>
              <Text style={[styles.summaryValue, { color: colors.glassText, fontFamily: FONT_MONO, fontSize: 13 }]} numberOfLines={1}>
                {daysUntilNext !== null ? `${daysUntilNext} gg` : '—'}
              </Text>
            </View>
          </View>
        </GlassView>
      )}

      {recurring.length === 0 ? (
        <EmptyState
          message="Nessuna transazione ricorrente"
          subMessage="Automatizza le tue entrate e uscite periodiche"
        />
      ) : (
        <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.scrollContent}>
          <View style={styles.sectionHeaderRow}>
            <Text style={[styles.sectionHeaderTitle, { color: colors.text }]}>In scadenza</Text>
            <Text style={[styles.sectionHeaderLink, { color: 'rgba(255,255,255,0.7)' }]}>Calendario</Text>
          </View>
          <GlassView intensity="regular" style={styles.listWrap} borderRadius={28}>
            {recurring.map((rec) => {
              const category = categories.find((c) => c.id === rec.category_id);
              const isIncome = rec.type === 'income';
              const active = rec.active === 1;
              return (
                <TouchableOpacity
                  key={rec.id}
                  activeOpacity={0.6}
                  onPress={() => handlePress(rec)}
                  onLongPress={() => setDeleteId(rec.id)}
                  style={styles.recRow}
                >
                  <View style={[styles.recIcon, { backgroundColor: (category?.color || colors.primary) + '28' }]}>
                    <CategoryIcon name={category?.name || ''} icon={category?.icon} size={22} color={category?.color || colors.primary} />
                  </View>
                  <View style={styles.recInfo}>
                    <Text style={[styles.recName, { color: colors.glassText }]} numberOfLines={1}>
                      {rec.description || category?.name || 'Senza descrizione'}
                    </Text>
                    <Text style={[styles.recMeta, { color: 'rgba(255,255,255,0.62)' }]}>
                      {getFrequencyLabel(rec.frequency)} · {formatDate(rec.next_due_date)}
                    </Text>
                  </View>
                  <View style={styles.recRight}>
                    <Text style={[styles.recAmt, { color: isIncome ? colors.incomeLight : colors.glassText, fontFamily: FONT_MONO }]}>
                      {isIncome ? '+' : '−'}{formatCurrency(rec.amount)}
                    </Text>
                    <TouchableOpacity
                      activeOpacity={0.7}
                      onPress={() => handleToggle(rec)}
                      style={[
                        styles.toggle,
                        active && styles.toggleOn,
                        { backgroundColor: active ? colors.mint : 'rgba(255,255,255,0.10)' },
                      ]}
                    >
                      <View style={[styles.toggleThumb, active && styles.toggleThumbOn]} />
                    </TouchableOpacity>
                  </View>
                </TouchableOpacity>
              );
            })}
          </GlassView>
        </ScrollView>
      )}

      <ConfirmDialog
        visible={deleteId !== null}
        title="Elimina transazione ricorrente"
        message="Sei sicuro di voler eliminare questa transazione ricorrente?"
        confirmText="Elimina" cancelText="Annulla"
        onConfirm={handleDelete} onCancel={() => setDeleteId(null)} danger
      />

      <TouchableOpacity
        style={styles.fab}
        activeOpacity={0.7}
        onPress={() => navigation.navigate('AddRecurring')}
      >
        <Text style={styles.fabText}>+</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', paddingHorizontal: 24, paddingTop: 54, paddingBottom: 4 },
  title: { fontSize: 26, fontWeight: '700', fontFamily: '-apple-system', letterSpacing: -0.4 },
  headerLabel: { fontSize: 13, fontWeight: '600', fontFamily: '-apple-system', letterSpacing: 0.3, marginBottom: 2 },
  summary: { marginHorizontal: 16, marginBottom: 8 },
  summaryRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 12, paddingHorizontal: 4 },
  summaryItem: { flex: 1, alignItems: 'center' },
  summaryDivider: { width: 1, height: 30 },
  summaryLabel: { fontSize: 10, fontWeight: '600', textTransform: 'uppercase', letterSpacing: 0.3, marginBottom: 4, fontFamily: '-apple-system' },
  summaryValue: { fontSize: 16, fontWeight: '800', fontFamily: '-apple-system', letterSpacing: -0.3 },
  scrollContent: { paddingBottom: 180 },
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
  listWrap: {
    marginHorizontal: 16,
    paddingVertical: 6,
    paddingHorizontal: 8,
  },
  recRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 13,
    paddingHorizontal: 6,
  },
  recIcon: {
    width: 42,
    height: 42,
    borderRadius: 15,
    alignItems: 'center',
    justifyContent: 'center',
  },
  recInfo: { flex: 1 },
  recName: { fontSize: 14.5, fontWeight: '600', fontFamily: '-apple-system' },
  recMeta: { fontSize: 11.5, fontFamily: '-apple-system', marginTop: 2 },
  recRight: { alignItems: 'flex-end' },
  recAmt: { fontSize: 14.5, fontWeight: '700', letterSpacing: -0.2 },
  toggle: {
    width: 42,
    height: 24,
    borderRadius: 14,
    marginTop: 6,
    paddingHorizontal: 3,
    justifyContent: 'center',
  },
  toggleOn: {},
  toggleThumb: {
    width: 18,
    height: 18,
    borderRadius: 9,
    backgroundColor: '#FFFFFF',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 3,
  },
  toggleThumbOn: {
    alignSelf: 'flex-end',
  },
  fab: {
    position: 'absolute',
    right: 22,
    bottom: 120,
    width: 56,
    height: 56,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.5)',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.3,
    shadowRadius: 24,
    elevation: 10,
  },
  fabText: {
    fontSize: 24,
    fontWeight: '600',
    color: '#FFFFFF',
    fontFamily: '-apple-system',
  },
});
