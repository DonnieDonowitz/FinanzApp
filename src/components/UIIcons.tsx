import React from 'react';
import Svg, { Path, Circle, Line, Rect } from 'react-native-svg';

interface IconProps {
  size?: number;
  color?: string;
  strokeWidth?: number;
}

const defaultSize = 24;
const defaultColor = '#666';
const defaultStroke = 1.8;

function makeIcon(PathElement: React.ReactNode) {
  return function Icon({ size = defaultSize, color = defaultColor, strokeWidth = defaultStroke }: IconProps) {
    return (
      <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
        {React.Children.map(PathElement as React.ReactElement, (child) => {
          if (React.isValidElement(child)) {
            return React.cloneElement(child as React.ReactElement<any>, {
              stroke: color,
              strokeWidth,
            });
          }
          return child;
        })}
      </Svg>
    );
  };
}

export const IconClose = makeIcon(<Path d="M6 6l12 12M18 6L6 18" strokeLinecap="round" />);

export const IconFilter = makeIcon(<>
  <Path d="M4 4h16l-6 8v6l-4 2v-8L4 4z" strokeLinecap="round" strokeLinejoin="round"/>
</>);

export const IconFilterActive = makeIcon(<>
  <Path d="M4 4h16l-6 8v6l-4 2v-8L4 4z" strokeLinecap="round" strokeLinejoin="round"/>
  <Circle cx="20" cy="4" r="3" fill="currentColor" stroke="none"/>
</>);

export const IconArrowLeft = makeIcon(<>
  <Path d="M15 18l-6-6 6-6" strokeLinecap="round" strokeLinejoin="round"/>
</>);

export const IconArrowRight = makeIcon(<>
  <Path d="M9 6l6 6-6 6" strokeLinecap="round" strokeLinejoin="round"/>
</>);

export const IconArrowDown = makeIcon(<>
  <Path d="M12 5v14M5 13l7 7 7-7" strokeLinecap="round" strokeLinejoin="round"/>
</>);

export const IconArrowUp = makeIcon(<>
  <Path d="M12 19V5M5 11l7-7 7 7" strokeLinecap="round" strokeLinejoin="round"/>
</>);

export const IconPlus = makeIcon(<>
  <Path d="M12 5v14M5 12h14" strokeLinecap="round"/>
</>);

export const IconMinus = makeIcon(<>
  <Path d="M5 12h14" strokeLinecap="round"/>
</>);

export const IconList = makeIcon(<>
  <Line x1="7" y1="7" x2="17" y2="7" strokeLinecap="round"/>
  <Line x1="7" y1="12" x2="17" y2="12" strokeLinecap="round"/>
  <Line x1="7" y1="17" x2="17" y2="17" strokeLinecap="round"/>
  <Circle cx="4" cy="7" r="1" fill="currentColor" stroke="none"/>
  <Circle cx="4" cy="12" r="1" fill="currentColor" stroke="none"/>
  <Circle cx="4" cy="17" r="1" fill="currentColor" stroke="none"/>
</>);

export const IconCalendar = makeIcon(<>
  <Rect x="3" y="4" width="18" height="16" rx="2" strokeLinecap="round"/>
  <Line x1="3" y1="10" x2="21" y2="10" strokeLinecap="round"/>
  <Line x1="8" y1="2" x2="8" y2="6" strokeLinecap="round"/>
  <Line x1="16" y1="2" x2="16" y2="6" strokeLinecap="round"/>
</>);

export const IconChart = makeIcon(<>
  <Rect x="3" y="14" width="4" height="6" rx="1" strokeLinecap="round"/>
  <Rect x="10" y="10" width="4" height="10" rx="1" strokeLinecap="round"/>
  <Rect x="17" y="4" width="4" height="16" rx="1" strokeLinecap="round"/>
</>);

export const IconChartPie = makeIcon(<>
  <Circle cx="12" cy="12" r="9" strokeLinecap="round"/>
  <Path d="M12 3v9h9" strokeLinecap="round" strokeLinejoin="round"/>
</>);

export const IconRepeat = makeIcon(<>
  <Path d="M17 2l4 4-4 4" strokeLinecap="round" strokeLinejoin="round"/>
  <Path d="M3 11V9a4 4 0 014-4h14" strokeLinecap="round" strokeLinejoin="round"/>
  <Path d="M7 22l-4-4 4-4" strokeLinecap="round" strokeLinejoin="round"/>
  <Path d="M21 13v2a4 4 0 01-4 4H3" strokeLinecap="round" strokeLinejoin="round"/>
</>);

export const IconInbox = makeIcon(<>
  <Path d="M3 12h4l3 9h4l3-9h4" strokeLinecap="round" strokeLinejoin="round"/>
  <Path d="M21 12V5a2 2 0 00-2-2H5a2 2 0 00-2 2v7" strokeLinecap="round" strokeLinejoin="round"/>
</>);

export const IconRefresh = makeIcon(<>
  <Path d="M4 12a8 8 0 0114.93-4" strokeLinecap="round"/>
  <Path d="M20 12a8 8 0 01-14.93 4" strokeLinecap="round"/>
  <Path d="M18 4v4h-4" strokeLinecap="round" strokeLinejoin="round"/>
  <Path d="M6 20v-4h4" strokeLinecap="round" strokeLinejoin="round"/>
</>);

export const IconSettings = makeIcon(<>
  <Circle cx="12" cy="12" r="3" strokeLinecap="round"/>
  <Path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z" strokeLinecap="round" strokeLinejoin="round"/>
</>);

export const IconTrash = makeIcon(<>
  <Path d="M4 7h16M10 11v6M14 11v6M5 7l1 12a2 2 0 002 2h8a2 2 0 002-2l1-12M9 7V4a1 1 0 011-1h4a1 1 0 011 1v3" strokeLinecap="round" strokeLinejoin="round"/>
</>);

export const IconPencil = makeIcon(<>
  <Path d="M4 20h4L18.5 9.5a2.12 2.12 0 00-3-3L4 17v3z" strokeLinecap="round" strokeLinejoin="round"/>
  <Path d="M13.5 6.5l3 3" strokeLinecap="round"/>
</>);

export const IconWarning = makeIcon(<>
  <Path d="M12 9v4M12 17h.01" strokeLinecap="round"/>
  <Path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" strokeLinecap="round" strokeLinejoin="round"/>
</>);

export const IconInfo = makeIcon(<>
  <Circle cx="12" cy="12" r="10" strokeLinecap="round"/>
  <Line x1="12" y1="16" x2="12" y2="12" strokeLinecap="round"/>
  <Line x1="12" y1="8" x2="12.01" y2="8" strokeLinecap="round"/>
</>);

export const IconEmptySearch = makeIcon(<>
  <Circle cx="11" cy="11" r="7" strokeLinecap="round"/>
  <Path d="M16 16l4.5 4.5" strokeLinecap="round"/>
  <Line x1="8" y1="11" x2="14" y2="11" strokeLinecap="round"/>
</>);
