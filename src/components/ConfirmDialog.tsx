import React from 'react';
import { Modal, View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useTheme } from '../hooks/useTheme';
import Svg, { Path } from 'react-native-svg';
import { GlassView } from './GlassView';

interface ConfirmDialogProps {
  visible: boolean;
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  onConfirm: () => void;
  onCancel: () => void;
  danger?: boolean;
}

export function ConfirmDialog({ visible, title, message, confirmText = 'Conferma', cancelText = 'Annulla', onConfirm, onCancel, danger }: ConfirmDialogProps) {
  const { colors } = useTheme();

  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onCancel}>
      <View style={[styles.overlay, { backgroundColor: colors.overlay }]}>
        <GlassView intensity="strong" borderRadius={22} noHighlight style={styles.dialog}>
          {danger && (
            <View style={[styles.iconRow, { backgroundColor: colors.dangerSoft }]}>
              <Svg width={22} height={22} viewBox="0 0 24 24" fill="none">
                <Path d="M12 9v4M12 17h.01" stroke={colors.danger} strokeWidth={2} strokeLinecap="round" />
                <Path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" stroke={colors.danger} strokeWidth={1.6} strokeLinecap="round" strokeLinejoin="round" />
              </Svg>
            </View>
          )}
          <Text style={[styles.title, { color: colors.glassText }]}>{title}</Text>
          <Text style={[styles.message, { color: colors.glassTextSecondary }]}>{message}</Text>
          <View style={styles.buttons}>
            <GlassView intensity="regular" borderRadius={14} noHighlight style={styles.cancelBtn}>
              <TouchableOpacity style={styles.btnInner} activeOpacity={0.6} onPress={onCancel}>
                <Text style={[styles.btnText, { color: colors.glassTextSecondary }]}>{cancelText}</Text>
              </TouchableOpacity>
            </GlassView>
            <TouchableOpacity style={[styles.confirmBtn, { backgroundColor: danger ? colors.danger : colors.primary }]} activeOpacity={0.6} onPress={onConfirm}>
              <Text style={[styles.btnText, { color: '#fff' }]}>{confirmText}</Text>
            </TouchableOpacity>
          </View>
        </GlassView>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20 },
  dialog: {
    width: '100%', maxWidth: 340, padding: 24,
  },
  iconRow: {
    width: 44, height: 44, borderRadius: 12, alignItems: 'center', justifyContent: 'center',
    marginBottom: 14, alignSelf: 'flex-start',
  },
  title: { fontSize: 18, fontWeight: '700', fontFamily: '-apple-system', marginBottom: 6, letterSpacing: -0.2 },
  message: { fontSize: 14, lineHeight: 20, marginBottom: 22, fontFamily: '-apple-system' },
  buttons: { flexDirection: 'row', gap: 10 },
  btnInner: { flex: 1, paddingVertical: 13, alignItems: 'center' },
  cancelBtn: { flex: 1 },
  confirmBtn: { flex: 1, paddingVertical: 13, borderRadius: 14, alignItems: 'center' },
  btnText: { fontSize: 14, fontWeight: '700', fontFamily: '-apple-system' },
});
