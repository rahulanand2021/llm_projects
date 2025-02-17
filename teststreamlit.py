import streamlit as st
from streamlit.components.v1 import html

# st.write("Hover over the icon: :information_source:", help="This is a tooltip!")

# # Method 2: Using HTML and FontAwesome
# html_string = """
# <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
# <i class="fas fa-info-circle" title="This is a custom tooltip"></i>
# """
# html(html_string, height=20)

# Method 3: Using markdown with title attribute
tooltip_text = "This is your dynamic tooltip\
                \nMultiLine - 1\
                \nMultiLine -2\
                \nMultiLine -3 \
                \nMultiLine -4 "

st.markdown(f'<b class="material-icons" title="{tooltip_text}">:information_source:</b>', unsafe_allow_html=True)

st.markdown(f'<b class="material-icons" title="{tooltip_text}">:warning:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:bulb:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:question:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:exclamation:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:memo:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:book:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:computer:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:gear:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:lock:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:unlock:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:key:</b>', unsafe_allow_html=True)



st.markdown(f'<b class="material-icons" title="{tooltip_text}">:email:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:link:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:clipboard:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:battery:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:arrow_up:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:arrow_down:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:arrow_left:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:arrow_right:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:arrow_forward:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:arrow_backward:</b>', unsafe_allow_html=True)



st.markdown(f'<b class="material-icons" title="{tooltip_text}">:cloud:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:rainbow:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:star:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:thumbsup:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:thumbsdown:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:heart:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:smile:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:chart_with_upwards_trend:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:chart_with_downwards_trend:</b>', unsafe_allow_html=True)
st.markdown(f'<b class="material-icons" title="{tooltip_text}">:fire:</b>', unsafe_allow_html=True)

import streamlit as st

# Add custom CSS for tooltip styling
st.markdown("""
    <style>
    /* Custom tooltip style */
    .custom-tooltip {
        position: relative;
        display: inline-block;
    }

    .custom-tooltip:hover::before {
        content: attr(data-tooltip);
        position: absolute;
        bottom: 100%;
        left: 50%;
        transform: translateX(-50%);
        padding: 8px;
        background-color: #333;
        color: white;
        border-radius: 6px;
        font-size: 14px;
        white-space: nowrap;
        z-index: 1000;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }
    </style>
""", unsafe_allow_html=True)

# Using the custom tooltip
st.markdown("""
    <span class="custom-tooltip" data-tooltip="This is a custom styled tooltip">
        ℹ️
    </span>
""", unsafe_allow_html=True)

# Different styling example with arrow
st.markdown("""
    <style>
    .tooltip-with-arrow {
        position: relative;
        display: inline-block;
    }

    .tooltip-with-arrow:hover::before {
        content: attr(data-tooltip);
        position: absolute;
        bottom: 100%;
        left: 50%;
        transform: translateX(-50%);
        padding: 8px;
        background-color: #2E86C1;
        color: white;
        border-radius: 4px;
        font-size: 12px;
        white-space: nowrap;
    }

    .tooltip-with-arrow:hover::after {
        content: "";
        position: absolute;
        top: -5px;
        left: 50%;
        transform: translateX(-50%);
        border-width: 5px;
        border-style: solid;
        border-color: #2E86C1 transparent transparent transparent;
    }
    </style>

    <span class="tooltip-with-arrow" data-tooltip="Tooltip with arrow and different color">
        ℹ️
    </span>
""", unsafe_allow_html=True)

tooltip_message = "This is your dynamic message- Rahul" 

# Animated tooltip example

# Your dynamic text
tooltip_message = "This is your dynamic message\
                \n Multiline"

# First, add the static CSS
st.markdown("""
    <style>
    .animated-tooltip {
        position: relative;
        display: inline-block;
    }

    .animated-tooltip:hover::before {
        content: attr(data-tooltip);
        position: absolute;
        bottom: 100%;
        left: 50%;
        transform: translateX(-50%);
        padding: 8px;
        background-color: #16A085;
        color: white;
        border-radius: 4px;
        font-size: 12px;
        white-space: nowrap;
        animation: fadeIn 0.3s ease-in-out;
    }

    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translate(-50%, 10px);
        }
        to {
            opacity: 1;
            transform: translate(-50%, 0);
        }
    }
    </style>
""", unsafe_allow_html=True)

tooltip_message = """Line 1 of the tooltip
Line 2 of the tooltip
Line 3 of the tooltip"""

tooltip_message_html = tooltip_message.replace('\n', '<br>')

# Then, add the dynamic HTML separately
st.markdown(f'<b class="animated-tooltip" data-tooltip="{tooltip_message}">ℹ️</b>', unsafe_allow_html=True)