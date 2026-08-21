import React, { useState } from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';
import { useTheme } from '../hooks/useTheme';
import { formatCurrency } from '../utils/format';
import Svg, { Rect, Circle, Line, Path, Text as SvgText, G } from 'react-native-svg';
import { GlassView } from './GlassView';

const SW = Dimensions.get('window').width;
const CHART_W = SW - 32;
const CHART_H = 200;

interface ChartViewProps {
  type: 'pie' | 'bar';
  title: string;
  data: any;
  labels?: string[];
  totalOverride?: number;
}

export function ChartView({ type, title, data, labels, totalOverride }: ChartViewProps) {
  const { colors } = useTheme();

  const renderEmptyState = () => (
    <View style={[styles.noData, { backgroundColor: colors.sectionBg, borderColor: colors.divider }]}>
      <Svg width={32} height={32} viewBox="0 0 24 24" fill="none">
        <Circle cx="12" cy="12" r="9" stroke={colors.textTertiary} strokeWidth={1.4} strokeOpacity={0.5} />
        <Path d="M12 7v5l3 3" stroke={colors.textTertiary} strokeWidth={1.4} strokeLinecap="round" strokeOpacity={0.5} />
        <Line x1="4" y1="4" x2="20" y2="20" stroke={colors.textTertiary} strokeWidth={1} strokeLinecap="round" strokeOpacity={0.2} />
      </Svg>
      <Text style={[styles.noDataText, { color: colors.glassTextTertiary }]}>Nessun dato</Text>
    </View>
  );

  const renderChart = () => {
    if (type === 'pie') {
      if (!data || !Array.isArray(data) || data.length === 0 || data.every((d: any) => !d.amount || d.amount === 0)) {
        return renderEmptyState();
      }
      return <PieChartSvg data={data} colors={colors} totalOverride={totalOverride} />;
    }

    if (!data || !Array.isArray(data) || data.length === 0 || data.every((v: number) => v === 0)) {
      return renderEmptyState();
    }

    return <BalanceBarChart data={data} labels={labels || []} colors={colors} />;
  };

  return (
    <GlassView intensity="regular" borderRadius={22} style={styles.container}>
      <Text style={[styles.title, { color: colors.glassText }]}>{title}</Text>
      <View style={styles.chartWrap}>{renderChart()}</View>
    </GlassView>
  );
}

// ── SVG Pie Chart (donut) ─────────────────────────────────────────────

function polarToCartesian(cx: number, cy: number, r: number, angleDeg: number) {
  const rad = (angleDeg - 90) * Math.PI / 180;
  return { x: cx + r * Math.cos(rad), y: cy + r * Math.sin(rad) };
}

function describeArc(cx: number, cy: number, r: number, startAngle: number, endAngle: number): string {
  const start = polarToCartesian(cx, cy, r, endAngle);
  const end = polarToCartesian(cx, cy, r, startAngle);
  const sweep = endAngle - startAngle;
  const largeArcFlag = sweep > 180 ? 1 : 0;
  return `M ${start.x} ${start.y} A ${r} ${r} 0 ${largeArcFlag} 0 ${end.x} ${end.y}`;
}

function PieChartSvg({ data, colors, totalOverride }: { data: any[]; colors: any; totalOverride?: number }) {
  const [activeIndex, setActiveIndex] = useState(-1);
  const size = 180;
  const cx = size / 2;
  const cy = size / 2;
  const outerR = 72;
  const innerR = 44;

  const total = totalOverride ?? data.reduce((s: number, d: any) => s + d.amount, 0);
  if (total === 0) return null;

  let cumAngle = 0;
  const rawSlices = data.map((item: any, i: number) => {
    const angle = (item.amount / total) * 360;
    const startAngle = cumAngle;
    cumAngle += angle;
    return { ...item, startAngle, endAngle: cumAngle, angle, index: i };
  });
  // Force the last slice to end at exactly 360° to close the donut
  if (rawSlices.length > 0) {
    rawSlices[rawSlices.length - 1].endAngle = 360;
  }
  const slices = rawSlices;

  const activeSlice = activeIndex >= 0 ? slices[activeIndex] : null;

  return (
    <View style={{ alignItems: 'center' }}>
      <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
        {slices.map((slice: any, i: number) => {
          const isActive = i === activeIndex;
          const fillColor = slice.color || colors.primary;

          // For a single slice covering ~360°, draw a full ring
          if (slice.angle >= 359.9) {
            return (
              <G key={i}>
                <Circle cx={cx} cy={cy} r={outerR} fill={fillColor} opacity={isActive ? 1 : 0.85} />
                <Circle cx={cx} cy={cy} r={innerR} fill={colors.card} />
              </G>
            );
          }

          const startOuter = polarToCartesian(cx, cy, outerR, slice.startAngle);
          const endOuter = polarToCartesian(cx, cy, outerR, slice.endAngle);
          const startInner = polarToCartesian(cx, cy, innerR, slice.startAngle);
          const endInner = polarToCartesian(cx, cy, innerR, slice.endAngle);

          // Draw donut segment: outer arc → line to inner end → inner arc (reverse) → line to outer start
          const d = [
            `M ${startOuter.x} ${startOuter.y}`,
            `A ${outerR} ${outerR} 0 ${slice.angle > 180 ? 1 : 0} 1 ${endOuter.x} ${endOuter.y}`,
            `L ${endInner.x} ${endInner.y}`,
            `A ${innerR} ${innerR} 0 ${slice.angle > 180 ? 1 : 0} 0 ${startInner.x} ${startInner.y}`,
            'Z',
          ].join(' ');

          return (
            <Path
              key={i}
              d={d}
              fill={fillColor}
              opacity={isActive ? 1 : 0.85}
              onPress={() => setActiveIndex(i === activeIndex ? -1 : i)}
            />
          );
        })}
        {/* Center text */}
        {activeSlice ? (
          <>
            <SvgText x={cx} y={cy - 4} textAnchor="middle" fill={colors.glassText}
              fontSize={14} fontWeight="700" fontFamily="-apple-system">
              {formatCurrency(activeSlice.amount)}
            </SvgText>
            <SvgText x={cx} y={cy + 12} textAnchor="middle" fill={colors.glassTextSecondary}
              fontSize={9} fontWeight="500" fontFamily="-apple-system">
              {activeSlice.name}
            </SvgText>
          </>
        ) : (
          <>
            <SvgText x={cx} y={cy - 2} textAnchor="middle" fill={colors.glassText}
              fontSize={13} fontWeight="700" fontFamily="-apple-system">
              {formatCurrency(total)}
            </SvgText>
            <SvgText x={cx} y={cy + 12} textAnchor="middle" fill={colors.glassTextTertiary}
              fontSize={9} fontWeight="500" fontFamily="-apple-system">
              Totale
            </SvgText>
          </>
        )}
      </Svg>
    </View>
  );
}

// ── Custom bar chart with green/red bars ──────────────────────────────

function BalanceBarChart({ data, labels, colors }: { data: number[]; labels: string[]; colors: any }) {
  const [hoveredIndex, setHoveredIndex] = useState(-1);

  const chartW = CHART_W;
  const chartH = 180;
  const padTop = 10;
  const padBot = 22;
  const padLeft = 44;
  const padRight = 8;
  const plotW = chartW - padLeft - padRight;
  const plotH = chartH - padTop - padBot;

  const maxAbs = Math.max(1, ...data.map(Math.abs));
  const zeroY = padTop + plotH / 2;
  const colW = plotW / data.length;
  const barW = Math.min(18, colW * 0.55);

  const niceMax = niceNum(maxAbs);
  const yTicks = [-niceMax, 0, niceMax];

  const hoveredVal = hoveredIndex >= 0 ? data[hoveredIndex] : null;
  const hoveredLabel = hoveredIndex >= 0 ? labels[hoveredIndex] : '';

  return (
    <View>
      <Svg width={chartW} height={chartH} viewBox={`0 0 ${chartW} ${chartH}`}>
        {/* Y-axis grid lines and labels */}
        {yTicks.map((tick, i) => {
          const y = zeroY - (tick / niceMax) * (plotH / 2);
          return (
            <G key={i}>
              {tick !== 0 && (
                <Line x1={padLeft} y1={y} x2={chartW - padRight} y2={y}
                  stroke={colors.divider} strokeWidth={0.5} strokeDasharray="3,3" />
              )}
              <Line x1={padLeft} y1={y} x2={chartW - padRight} y2={y}
                stroke={tick === 0 ? colors.divider : 'transparent'} strokeWidth={tick === 0 ? 1 : 0} />
              <SvgText x={padLeft - 6} y={y + 3} textAnchor="end"
                fill={colors.textTertiary} fontSize={8} fontFamily="-apple-system">
                {tick === 0 ? '€0' : `${Math.round(tick)}`}
              </SvgText>
            </G>
          );
        })}

        {/* Bars */}
        {data.map((val, i) => {
          const cx = padLeft + (i + 0.5) * colW;
          const x = cx - barW / 2;
          const isPositive = val >= 0;
          const isHovered = i === hoveredIndex;
          const barColor = isPositive ? colors.income : colors.expense;
          const barPixelH = (Math.abs(val) / niceMax) * (plotH / 2);
          const y = isPositive ? zeroY - barPixelH : zeroY;
          const h = Math.max(barPixelH, 2);

          return (
            <React.Fragment key={i}>
              <Rect
                x={padLeft + i * colW}
                y={padTop}
                width={colW}
                height={plotH}
                fill="transparent"
                onPressIn={() => setHoveredIndex(i)}
                onPressOut={() => setHoveredIndex(-1)}
              />
              <Rect x={x} y={y} width={barW} height={h}
                rx={4} ry={4} fill={barColor} opacity={isHovered ? 1 : 0.7} />
              <SvgText x={cx} y={chartH - 4} textAnchor="middle"
                fill={isHovered ? colors.glassText : colors.glassTextTertiary}
                fontSize={9} fontWeight={isHovered ? '700' : '500'} fontFamily="-apple-system">
                {labels[i] || ''}
              </SvgText>
            </React.Fragment>
          );
        })}
      </Svg>

      {/* Hover overlay */}
      {hoveredVal !== null && (
        <View style={[styles.tooltip, {
          backgroundColor: colors.glass,
          borderColor: colors.glassBorder,
          shadowColor: colors.shadow,
        }]}>
          <Text style={[styles.tooltipLabel, { color: colors.glassTextSecondary }]}>Saldo {hoveredLabel}</Text>
          <Text style={[styles.tooltipValue, { color: hoveredVal >= 0 ? colors.income : colors.expense }]}>
            {formatCurrency(hoveredVal)}
          </Text>
        </View>
      )}
    </View>
  );
}

function niceNum(val: number): number {
  const exp = Math.floor(Math.log10(val));
  const frac = val / Math.pow(10, exp);
  let nice: number;
  if (frac <= 1.5) nice = 1;
  else if (frac <= 3) nice = 2;
  else if (frac <= 7) nice = 5;
  else nice = 10;
  return nice * Math.pow(10, exp);
}

const styles = StyleSheet.create({
  container: {
    marginHorizontal: 16,
    marginBottom: 12,
    padding: 18,
  },
  title: { fontSize: 15, fontWeight: '700', fontFamily: '-apple-system', marginBottom: 14, textAlign: 'center', letterSpacing: -0.1 },
  chartWrap: { alignItems: 'center' },
  noData: { height: CHART_H, justifyContent: 'center', alignItems: 'center', borderRadius: 16, borderWidth: 0.5, borderStyle: 'dashed', gap: 8 },
  noDataText: { fontSize: 13, fontWeight: '500', fontFamily: '-apple-system' },
  tooltip: {
    position: 'absolute', top: 4, left: 0, right: 0, alignItems: 'center',
    paddingHorizontal: 16, paddingVertical: 8, borderRadius: 14, borderWidth: 0.5,
    shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.08, shadowRadius: 12, elevation: 4,
  },
  tooltipLabel: { fontSize: 11, fontWeight: '500', fontFamily: '-apple-system' },
  tooltipValue: { fontSize: 18, fontWeight: '800', fontFamily: '-apple-system', marginTop: 2, letterSpacing: -0.3 },
});
