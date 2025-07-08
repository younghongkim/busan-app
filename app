import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

st.set_page_config(layout="wide")
st.title("📊 부산항 일일운영현황 대시보드")

# 숫자형 변환 함수
def clean_numeric(df):
    for col in df.columns:
        if col != '날짜':
            df[col] = df[col].astype(str).str.replace(",", "")
            df[col] = pd.to_numeric(df[col], errors='coerce')
    return df

# 차트 그리기 함수
def plot_lines(df, title):
    fig, ax = plt.subplots()
    for col in df.columns:
        if col != '날짜':
            ax.plot(df['날짜'], df[col], label=col)
    ax.set_title(title)
    ax.set_xlabel("날짜")
    ax.set_ylabel("수치")
    ax.legend()
    ax.grid(True)
    return fig

# 파일 업로드
col1, col2 = st.columns(2)
with col1:
    ship_file = st.file_uploader("선박 데이터 업로드", type=["xlsx"])
with col2:
    cargo_file = st.file_uploader("컨테이너 화물 데이터 업로드", type=["xlsx"])

if ship_file and cargo_file:
    # 시트별 데이터 불러오기
    ship_domestic = pd.read_excel(ship_file, sheet_name='국적 일일')
    ship_foreign = pd.read_excel(ship_file, sheet_name='외국적 일일')
    cargo_domestic = pd.read_excel(cargo_file, sheet_name='국적 일일')
    cargo_foreign = pd.read_excel(cargo_file, sheet_name='외국적 일일')

    # 날짜 변환
    for df in [ship_domestic, ship_foreign, cargo_domestic, cargo_foreign]:
        df['날짜'] = pd.to_datetime(df['날짜'], format="%Y%m%d")

    # 쉼표 제거 및 숫자형 변환
    cargo_domestic = clean_numeric(cargo_domestic)
    cargo_foreign = clean_numeric(cargo_foreign)

    # 탭으로 분리
    tab1, tab2, tab3, tab4 = st.tabs(["🚢 선박 (국적)", "🚢 선박 (외국적)", "📦 컨테이너 (국적)", "📦 컨테이너 (외국적)"])

    with tab1:
        st.subheader("선박 - 국적")
        st.pyplot(plot_lines(ship_domestic, "선박 - 국적"))

    with tab2:
        st.subheader("선박 - 외국적")
        st.pyplot(plot_lines(ship_foreign, "선박 - 외국적"))

    with tab3:
        st.subheader("컨테이너 화물 - 국적")
        st.pyplot(plot_lines(cargo_domestic, "컨테이너 화물 - 국적"))

    with tab4:
        st.subheader("컨테이너 화물 - 외국적")
        st.pyplot(plot_lines(cargo_foreign, "컨테이너 화물 - 외국적"))
else:
    st.warning("선박 및 컨테이너 화물 파일을 업로드해 주세요.")
