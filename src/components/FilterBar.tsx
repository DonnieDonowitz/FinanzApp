import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView } from 'react-native';
import { useTheme } from '../hooks/useTheme';
import { TRANSACTION_FILTERS } from '../utils/constants';
import { GlassView } from './GlassView';

interface FilterBarProps {
  filterType: 'all' | 'income' | 'expense';
  onFilterTypeChange: (type: 'all' | 'income' | 'expense') => void;
  filterMonth: string;
  onMonthChange: (month: string) => void;
}

function getMonthOptions(): { value: string; label: string }[] {
  const options: { value: string; label: string }[] = [];
  const now = new Date();
  for (let i = 0; i < 12; i++) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    const value = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
    const label = new Intl.DateTimeFormat('it-IT', { month: 'long', year: 'numeric' }).format(d);
    options.push({ value, label });
  }
  return options;
}

export function FilterBar({ filterType, onFilterTypeChange, filterMonth, onMonthChange }: FilterBarProps) {
  const { colors } = useTheme();
  const monthOptions = getMonthOptions();

  return (
    <View style={styles.container}>
      <GlassView intensity="regular" style={styles.chipRow} borderRadius={20}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.row}>
          {TRANSACTION_FILTERS.map((f) => {
            const sel = filterType === f.value;
            return (
              <TouchableOpacity
                key={f.value}
                activeOpacity={0.6}
                style={[styles.chip, sel && styles.chipActive]}
                onPress={() => onFilterTypeChange(f.value as any)}
              >
                <Text style={[styles.chipText, { color: sel ? '#fff' : colors.glassTextSecondary }]}>{f.label}</Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      </GlassView>

      <GlassView intensity="regular" style={styles.chipRow} borderRadius={16}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.row}>
          {monthOptions.map((m) => {
            const sel = filterMonth === m.value;
            return (
              <TouchableOpacity
                key={m.value}
                activeOpacity={0.6}
                style={[styles.monthChip, sel && styles.monthChipActive]}
                onPress={() => onMonthChange(m.value)}
              >
                <Text style={[styles.monthText, { color: sel ? colors.primary : colors.glassTextSecondary }]}>
                  {m.label.charAt(0).toUpperCase() + m.label.slice(1)}
                </Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      </GlassView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { paddingVertical: 6, paddingBottom: 2 },
  chipRow: {
    marginHorizontal: 12,
    paddingHorizontal: 4,
    paddingVertical: 2,
  },
  row: { paddingHorizontal: 8, marginBottom: 2 },
  chip: {
    paddingHorizontal: 16,
    paddingVertical: 7,
    borderRadius: 20,
    marginRight: 8,
  },
  chipActive: {
    backgroundColor: 'transparent',
  },
  chipText: { fontSize: 13, fontWeight: '700', fontFamily: '-apple-system' },
  monthChip: {
    paddingHorizontal: 12,
    paddingVertical: 5,
    borderRadius: 10,
    marginRight: 6,
  },
  monthChipActive: {
    backgroundColor: 'transparent',
  },
  monthText: { fontSize: 11, fontWeight: '600', fontFamily: '-apple-system' },
});
