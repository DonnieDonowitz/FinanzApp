import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../hooks/useTheme';
import { formatCurrency, FONT_MONO } from '../utils/format';
import { GlassView } from './GlassView';

interface BalanceCardProps {
  income: number;
  expense: number;
}

export function BalanceCard({ income, expense }: BalanceCardProps) {
  const { colors } = useTheme();
  const [viewMode, setViewMode] = useState<'conto' | 'contanti'>('conto');
  const balance = viewMode === 'conto' ? income - expense : expense;

  const balanceStr = formatCurrency(balance);
  const euroIdx = balanceStr.indexOf('€');
  const digits = euroIdx >= 0 ? balanceStr.slice(euroIdx + 1) : balanceStr;
  const dotIdx = digits.indexOf(',');
  const intPart = dotIdx >= 0 ? digits.slice(0, dotIdx) : digits;
  const decPart = dotIdx >= 0 ? digits.slice(dotIdx) : '';

  return (
    <View style={[styles.container, { shadowColor: colors.shadow, borderColor: colors.glassStrongBorder }]}>
      <LinearGradient
        colors={['rgba(15,20,40,0.82)', 'rgba(45,55,95,0.65)', 'rgba(25,40,70,0.50)']}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={styles.gradientBg}
      />
      <LinearGradient
        colors={['rgba(255,255,255,0.18)', 'rgba(255,255,255,0)']}
        start={{ x: 0, y: 0 }}
        end={{ x: 0.5, y: 1 }}
        style={styles.highlight}
        pointerEvents="none"
      />
      <View style={styles.content}>
        <View style={styles.topRow}>
          <Text style={styles.monthLabel}>SALDO TOTALE</Text>
          <View style={[styles.pillToggle, { backgroundColor: 'rgba(255,255,255,0.10)', borderColor: 'rgba(255,255,255,0.18)' }]}>
            <TouchableOpacity
              activeOpacity={0.6}
              style={[styles.pillOption, viewMode === 'conto' && styles.pillActive]}
              onPress={() => setViewMode('conto')}
            >
              <Text style={[styles.pillText, viewMode === 'conto' && styles.pillTextActive]}>Conto</Text>
            </TouchableOpacity>
            <TouchableOpacity
              activeOpacity={0.6}
              style={[styles.pillOption, viewMode === 'contanti' && styles.pillActive]}
              onPress={() => setViewMode('contanti')}
            >
              <Text style={[styles.pillText, viewMode === 'contanti' && styles.pillTextActive]}>Contanti</Text>
            </TouchableOpacity>
          </View>
        </View>

        <Text style={[styles.amount, { color: balance >= 0 ? '#2FE8B0' : '#FF7A7A' }]}>
          {intPart}
          <Text style={styles.amountDec}>{decPart}</Text>
        </Text>

        <View style={styles.flowRow}>
          <GlassView intensity="regular" style={styles.flowChip} borderRadius={20} noHighlight>
            <View style={styles.iconLine}>
              <View style={[styles.dot, { backgroundColor: colors.mint, shadowColor: colors.mintGlow }]} />
              <Text style={styles.flowLabel}>Entrate</Text>
            </View>
            <Text style={[styles.flowValue, { color: colors.income }]}>+{formatCurrency(income)}</Text>
          </GlassView>

          <GlassView intensity="regular" style={styles.flowChip} borderRadius={20} noHighlight>
            <View style={styles.iconLine}>
              <View style={[styles.dot, { backgroundColor: colors.coral, shadowColor: colors.coralGlow }]} />
              <Text style={styles.flowLabel}>Uscite</Text>
            </View>
            <Text style={[styles.flowValue, { color: colors.expense }]}>-{formatCurrency(expense)}</Text>
          </GlassView>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginHorizontal: 16,
    marginTop: 10,
    marginBottom: 8,
    borderRadius: 28,
    borderWidth: 1,
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.35,
    shadowRadius: 32,
    elevation: 10,
    overflow: 'hidden',
  },
  gradientBg: {
    ...StyleSheet.absoluteFillObject,
  },
  highlight: {
    ...StyleSheet.absoluteFillObject,
  },
  content: {
    padding: 22,
  },
  topRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  monthLabel: {
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 0.5,
    color: 'rgba(255,255,255,0.75)',
  },
  pillToggle: {
    flexDirection: 'row',
    borderRadius: 14,
    borderWidth: 0.5,
    padding: 2,
  },
  pillOption: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
  },
  pillActive: {
    backgroundColor: 'rgba(255,255,255,0.92)',
  },
  pillText: {
    fontSize: 11,
    fontWeight: '700',
    color: 'rgba(255,255,255,0.6)',
  },
  pillTextActive: {
    color: '#000',
  },
  amount: {
    fontFamily: FONT_MONO,
    fontSize: 38,
    fontWeight: '700',
    letterSpacing: -1,
    marginTop: 6,
    marginBottom: 14,
  },
  amountDec: {
    fontSize: 18,
    opacity: 0.7,
  },
  flowRow: {
    flexDirection: 'row',
    gap: 10,
  },
  flowChip: {
    flex: 1,
    padding: 14,
  },
  iconLine: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 6,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    shadowRadius: 10,
    elevation: 4,
  },
  flowLabel: {
    fontSize: 12,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 0.3,
    color: 'rgba(255,255,255,0.75)',
  },
  flowValue: {
    fontFamily: FONT_MONO,
    fontSize: 18,
    fontWeight: '700',
  },
});
