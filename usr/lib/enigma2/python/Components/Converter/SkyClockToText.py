# Embedded file name: /usr/lib/enigma2/python/Components/Converter/SkyClockToText.py
from Converter import Converter
from Components.Sources.Clock import Clock
from time import time as getTime, localtime, strftime
from Poll import Poll
from Components.Element import cached

class SkyClockToText(Converter, object):
    DEFAULT = 0
    FORMAT = 1
    SKY_AS_LENGTH = 2
    SKY_Q_DATE = 3
    SKY_HD_DATE = 4
    SKY_HD_TIME = 5
    SKY_HD_STARTPROGRESS = 6
    SKY_Q_STARTTIME = 7
    SKY_HD_ENDTIME = 8


    def __init__(self, type):
        Converter.__init__(self, type)
        self.fix = ''
        if ';' in type:
            type, self.fix = type.split(';')
        if type == 'SkyAsLength':
            self.type = self.SKY_AS_LENGTH
        elif type == 'SkyQDate':
            self.type = self.SKY_Q_DATE
        elif type == 'SkyHDDate':
            self.type = self.SKY_HD_DATE
        elif type == 'SkyHDTime':
            self.type = self.SKY_HD_TIME
        elif type == 'SkyQStartTime':
            self.type = self.SKY_Q_STARTTIME
        elif type == "SkyHDEndTime":
			self.type = self.SKY_HD_ENDTIME
        elif 'Format' in type:
            self.type = self.FORMAT
            self.fmt_string = type[8:]
        else:
            self.type = self.DEFAULT

    @cached
    def getText(self):
        time = self.source.time
        t = localtime(time)
        tnow = getTime()
        if time is None:
            return ''
        else:

            def fix_space(string):
                if 'Proportional' in self.fix and t.tm_hour < 10:
                    return ' ' + string
                if 'NoSpace' in self.fix:
                    return string.lstrip(' ')
                return string

            if self.type == self.SKY_AS_LENGTH:
                if time <= 9:
                    return ''
                elif time / 3600 < 1:
                    return ngettext('%d Min', '%d Mins', time / 60) % (time / 60)
                elif time / 60 % 60 == 0:
                    return ngettext('%d Hour', '%d Hours', time / 3600) % (time / 3600)
                else:
                    return '%dh %2dm' % (time / 3600, time / 60 % 60)
            if int(strftime('%H', t)) >= 12:
                timesuffix = _('pm')
            else:
                timesuffix = _('am')
            if self.type == self.DEFAULT:
                return fix_space(_('%2d:%02d') % (t.tm_hour, t.tm_min))
            if self.type == self.SKY_Q_DATE:
                d = _('%A, %l.%M') + _(timesuffix)
            elif self.type == self.SKY_HD_DATE:
                d = _('%l.%M') + _(timesuffix) + _(' %a %d/%m')
            elif self.type == self.SKY_HD_TIME:
                d = _('%l.%M') + _(timesuffix)
            elif self.type == self.SKY_Q_STARTTIME:
                if time < tnow:
                    d = _('Started at ') + _('%l.%M').lstrip(' ') + _(timesuffix)
                else:
                    d = _('Starts at ') + _('%l.%M').lstrip(' ') + _(timesuffix)
            elif self.type == self.SKY_HD_ENDTIME:
			d = _("-  %l.%M") + _(timesuffix)

            elif self.type == self.FORMAT:
                d = self.fmt_string
            else:
                return '???'
            timetext = strftime(d, t)
            return timetext.lstrip(' ')

    text = property(getText)