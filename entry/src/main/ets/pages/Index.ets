class SwipeRecord {
  speed: number = 0
  direction: string = ''
  timestamp: number = 0
}

@Entry
@Component
struct SwipeSpeedMeter {
  @State currentSpeed: number = 0
  @State maxSpeed: number = 0
  @State avgSpeed: number = 0
  @State swipeCount: number = 0
  @State _direction: string = '—'
  @State isTracking: boolean = false
  @State speedHistory: number[] = []
  @State speedLevel: string = 'slow'

  private startX: number = 0
  private startY: number = 0
  private startTime: number = 0
  private records: SwipeRecord[] = []

  private calculateSpeed(endX: number, endY: number): SwipeRecord {
    const dx = endX - this.startX
    const dy = endY - this.startY
    const distance = Math.sqrt(dx * dx + dy * dy)
    const elapsed = (Date.now() - this.startTime) / 1000

    let record = new SwipeRecord()

    if (elapsed > 0.005 && distance > 5) {
      record.speed = Math.round(distance / elapsed)
      record.timestamp = Date.now()

      if (Math.abs(dx) > Math.abs(dy)) {
        record.direction = dx > 0 ? '→ Right' : '← Left'
      } else {
        record.direction = dy > 0 ? '↓ Down' : '↑ Up'
      }
    }

    return record
  }

  private updateStats(record: SwipeRecord): void {
    this.records.push(record)
    this.currentSpeed = record.speed
    this._direction = record.direction
    this.swipeCount = this.records.length

    if (record.speed > this.maxSpeed) {
      this.maxSpeed = record.speed
    }

    let total = 0
    for (let r of this.records) {
      total += r.speed
    }
    this.avgSpeed = Math.round(total / this.records.length)

    this.speedHistory = this.records
      .slice(-10)
      .map(r => r.speed)

    if (record.speed < 800) {
      this.speedLevel = 'slow'
    } else if (record.speed < 2000) {
      this.speedLevel = 'medium'
    } else {
      this.speedLevel = 'fast'
    }
  }

  private resetAll(): void {
    this.currentSpeed = 0
    this.maxSpeed = 0
    this.avgSpeed = 0
    this.swipeCount = 0
    this._direction = '—'
    this.speedHistory = []
    this.speedLevel = 'slow'
    this.records = []
  }

  private getSpeedColor(): ResourceColor {
    switch (this.speedLevel) {
      case 'fast':
        return '#E24B4A'
      case 'medium':
        return '#EF9F27'
      default:
        return '#1D9E75'
    }
  }

  private getBarColor(speed: number): ResourceColor {
    if (speed >= 2000) {
      return '#E24B4A'
    }
    if (speed >= 800) {
      return '#EF9F27'
    }
    return '#1D9E75'
  }

  private getGaugeProgress(): number {
    const MAX = 4000
    return Math.min(this.currentSpeed / MAX, 1.0) * 100
  }

  build() {
    Scroll() {
        Column() {
          Text('SWIPE SPEED')
            .fontSize(11)
            .fontColor('#777777')
            .fontWeight(FontWeight.Medium)
            .letterSpacing(2)
            .margin({ top: 12 , bottom: 4})

          Stack() {
            Progress({
              value: 100,
              total: 100,
              type: ProgressType.Ring
            })
              .width(100)
              .height(100)
              .color('#2A2A2E')
              .backgroundColor('#2A2A2E')
              .style({ strokeWidth: 12 })

            Progress({
              value: this.getGaugeProgress(),
              total: 100,
              type: ProgressType.Ring
            })
              .width(100)
              .height(100)
              .color(this.getSpeedColor())
              .style({ strokeWidth: 12 })
              .animation({
                duration: 300,
                curve: Curve.EaseOut
              })
              .margin(3)

            Column() {
              Text(this.currentSpeed.toString())
                .fontSize(24)
                .fontColor(this.getSpeedColor())
                .fontWeight(FontWeight.Medium)
                .fontFamily('monospace')
                .animation({
                  duration: 200,
                  curve: Curve.EaseOut
                })

              Text('px/s')
                .fontSize(10)
                .fontColor('#888888')
                .fontFamily('monospace')
                .margin({ top: -4 })
            }

            Text(this._direction)
              .fontSize(10)
              .fontColor(this.currentSpeed > 0 ? this.getSpeedColor() : '#555555')
              .position({ x: '50%', y: '70%' })
              .translate({ x: '-50%' })
          }
          .width(100)
          .height(100)
          .margin({ top: 4 })

          Column() {
            Text(this.isTracking ? '· · ·' : '← Swipe →')
              .fontSize(11)
              .fontColor('#555555')
          }
          .width(180)
          .height(44)
          .borderRadius(22)
          .backgroundColor('rgba(255,255,255,0.04)')
          .border({ width: 0.5, color: 'rgba(255,255,255,0.08)' })
          .justifyContent(FlexAlign.Center)
          .margin({ top: 4 })
          .gesture(
            PanGesture({ direction: PanDirection.All })
              .onActionStart((event: GestureEvent) => {
                this.isTracking = true
                this.startX = event.offsetX
                this.startY = event.offsetY
                this.startTime = Date.now()
              })
              .onActionEnd((event: GestureEvent) => {
                this.isTracking = false
                const record = this.calculateSpeed(event.offsetX, event.offsetY)
                if (record.speed > 0) {
                  this.updateStats(record)
                }
              })
              .onActionCancel(() => {
                this.isTracking = false
              })
          )

          Row() {
            Column() {
              Text('Avg')
                .fontSize(9)
                .fontColor('#777777')
              Text(this.avgSpeed > 0 ? this.avgSpeed.toString() : '—')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .fontFamily('monospace')
                .fontWeight(FontWeight.Medium)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Divider()
              .vertical(true)
              .height(24)
              .color('#333333')

            Column() {
              Text('Max')
                .fontSize(9)
                .fontColor('#777777')
              Text(this.maxSpeed > 0 ? this.maxSpeed.toString() : '—')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .fontFamily('monospace')
                .fontWeight(FontWeight.Medium)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Divider()
              .vertical(true)
              .height(24)
              .color('#333333')

            Column() {
              Text('Num')
                .fontSize(9)
                .fontColor('#777777')
              Text(this.swipeCount.toString())
                .fontSize(16)
                .fontColor('#FFFFFF')
                .fontFamily('monospace')
                .fontWeight(FontWeight.Medium)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('85%')
          .height(44)
          .margin({ top: 6 })
          .backgroundColor('rgba(255,255,255,0.03)')
          .borderRadius(12)
          .padding({ left: 8, right: 8 })

          if (this.speedHistory.length > 0) {
            Row() {
              ForEach(this.speedHistory, (speed: number) => {
                Column()
                  .width(12)
                  .height(Math.max((speed / Math.max(...this.speedHistory, 500)) * 28, 3))
                  .borderRadius(3)
                  .backgroundColor(this.getBarColor(speed))
                  .animation({
                    duration: 200,
                    curve: Curve.EaseOut
                  })
              }, (index: number) => index.toString())
            }
            .width('75%')
            .height(32)
            .alignItems(VerticalAlign.Bottom)
            .justifyContent(FlexAlign.SpaceEvenly)
            .margin(4)
          }

          Text('Reset')
            .fontSize(10)
            .fontColor('#777777')
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .borderRadius(10)
            .border({ width: 0.5, color: '#444444' })
            .margin(10)
            .onClick(() => {
              this.resetAll()
            })
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Start)
    }.width('100%')
    .height('100%')

  }
}
